const time = document.getElementById('time');
const pad = (n) => String(n).padStart(2, '0');
const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const tick = () => {
  const d = new Date();
  const date = `${d.getFullYear()}/${pad(d.getMonth() + 1)}/${pad(d.getDate())}(${days[d.getDay()]})`;
  time.textContent = `${date} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
};
tick();
setInterval(tick, 1000);

document.addEventListener('contextmenu', (e) => {
  e.preventDefault();
  window.__TAURI__.core.invoke('show_menu');
});
