const app = document.getElementById('app');
const tabArea = document.getElementById('tabArea');
const title = document.getElementById('title');
const progress = document.getElementById('progress');
const closeBtn = document.getElementById('close');
const doneBtn = document.getElementById('done');

let state = {
    open: false,
    tabId: null,
    lineCount: 0,
    currentLine: 1,
    revealed: 0,
    dragging: false,
    dragLine: null
};

function nui(event, data = {}) {
    return fetch(`https://${GetParentResourceName()}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data)
    });
}

function formatPrize(result) {
    if (!result || !result.won) return 'NO PRIZE';

    return result.text || 'WINNER';
}

function createLine(index, image) {
    const line = document.createElement('div');
    line.className = 'line';
    line.dataset.line = index;

    const prize = document.createElement('div');
    prize.className = 'prize';
    prize.innerHTML = `
        <div class="line-label">Line ${index}</div>
        <div class="prize-text">WAITING...</div>
    `;

    const cover = document.createElement('div');
    cover.className = 'cover';
    cover.style.backgroundImage = `url("${image}")`;
    cover.innerHTML = `<div class="cover-shade"></div>`;

    const handle = document.createElement('div');
    handle.className = 'pull-handle';
    handle.dataset.line = index;

    cover.appendChild(handle);
    line.appendChild(prize);
    line.appendChild(cover);
    tabArea.appendChild(line);

    handle.addEventListener('pointerdown', startDrag);
}

function startDrag(e) {
    const handle = e.currentTarget;
    const line = handle.closest('.line');
    const lineNumber = Number(line.dataset.line);

    if (lineNumber !== state.currentLine || line.classList.contains('revealed')) {
        return;
    }

    e.preventDefault();
    handle.setPointerCapture(e.pointerId);

    state.dragging = true;
    state.dragLine = line;

    const rect = line.getBoundingClientRect();
    const startX = e.clientX;
    const maxX = rect.width - handle.offsetWidth - 14;

    function move(ev) {
        if (!state.dragging) return;

        let dx = ev.clientX - startX;
        dx = Math.max(0, Math.min(dx, maxX));

        handle.style.transform = `translateX(${dx}px)`;

        // The player must pull essentially the entire strip.
        if (dx >= maxX * 0.92) {
            revealLine(line);
            cleanup();
        }
    }

    function up() {
        cleanup();
    }

    function cleanup() {
        state.dragging = false;
        state.dragLine = null;
        document.removeEventListener('pointermove', move);
        document.removeEventListener('pointerup', up);
    }

    document.addEventListener('pointermove', move);
    document.addEventListener('pointerup', up);
}

function revealLine(line) {
    if (line.classList.contains('revealed')) return;

    const lineNumber = Number(line.dataset.line);
    if (lineNumber !== state.currentLine) return;

    line.classList.add('revealed');
    state.revealed++;

    nui('pullLine', { line: lineNumber });

    progress.textContent = `Revealed ${state.revealed}/${state.lineCount}`;

    if (state.revealed >= state.lineCount) {
        doneBtn.disabled = false;
        progress.textContent = 'All tabs pulled — check your winnings!';
    } else {
        state.currentLine++;
        progress.textContent = `Pull line ${state.currentLine} of ${state.lineCount}`;
    }
}

function openTab(data) {
    state = {
        open: true,
        tabId: data.tabId,
        lineCount: Number(data.lineCount),
        currentLine: 1,
        revealed: 0,
        dragging: false,
        dragLine: null
    };

    app.classList.remove('hidden');
    title.textContent = data.label || 'Pull Tab';
    tabArea.innerHTML = '';
    doneBtn.disabled = true;

    for (let i = 1; i <= state.lineCount; i++) {
        createLine(i, data.image || '');
    }

    progress.textContent = `Pull line 1 of ${state.lineCount}`;
}

function setLineResult(lineIndex, result) {
    const line = document.querySelector(`.line[data-line="${lineIndex}"]`);
    if (!line) return;

    const text = line.querySelector('.prize-text');
    text.textContent = formatPrize(result);

    if (result && result.won) {
        text.style.fontWeight = '900';
    }
}

function closeTab(sendServer = true) {
    if (!state.open) return;

    state.open = false;
    app.classList.add('hidden');

    if (sendServer) {
        nui('close');
    }
}

closeBtn.addEventListener('click', () => closeTab(true));

doneBtn.addEventListener('click', () => {
    if (state.revealed < state.lineCount) return;

    nui('finish');
    closeTab(false);
});

document.addEventListener('keydown', (e) => {
    if (!state.open) return;

    if (e.key === 'Escape') {
        closeTab(true);
    }
});

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'open') {
        openTab(data);
    }

    if (data.action === 'lineResult') {
        setLineResult(Number(data.line), data.result);
    }

    if (data.action === 'close') {
        closeTab(false);
    }
});
