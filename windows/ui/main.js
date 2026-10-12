const time = document.getElementById('time');
const pad = (n) => String(n).padStart(2, '0');
const tick = () => {
  const d = new Date();
  time.textContent = `${pad(d.getHours())}:${pad(d.getMinutes())}`;
};
tick();
setInterval(tick, 1000);

document.addEventListener('contextmenu', (e) => {
  e.preventDefault();
  window.__TAURI__.core.invoke('show_menu');
});
