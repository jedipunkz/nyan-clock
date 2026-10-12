// No console window in release builds.
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use serde::{Deserialize, Serialize};
use std::{fs, path::Path};
use tauri::{
    menu::{CheckMenuItem, Menu, MenuItem, PredefinedMenuItem},
    tray::TrayIconBuilder,
    AppHandle, Manager, State, Window, Wry,
};
use tauri_plugin_window_state::{AppHandleExt, StateFlags};

#[derive(Serialize, Deserialize, Clone, Copy)]
#[serde(default)]
struct Settings {
    always_on_top: bool,
    show_tray_icon: bool,
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            always_on_top: true,
            show_tray_icon: true,
        }
    }
}

fn load(path: &Path) -> Settings {
    fs::read(path)
        .ok()
        .and_then(|b| serde_json::from_slice(&b).ok())
        .unwrap_or_default()
}

fn save(path: &Path, s: Settings) {
    let res = fs::create_dir_all(path.parent().unwrap())
        .and_then(|_| fs::write(path, serde_json::to_vec(&s).unwrap()));
    if let Err(e) = res {
        eprintln!("failed to save {}: {e}", path.display());
    }
}

fn apply(app: &AppHandle, s: Settings) {
    if let Some(w) = app.get_webview_window("main") {
        let _ = w.set_always_on_top(s.always_on_top);
    }
    if let Some(t) = app.tray_by_id("main") {
        let _ = t.set_visible(s.show_tray_icon);
    }
}

/// Right-click on the clock: show the same menu as the tray icon.
#[tauri::command]
fn show_menu(window: Window, menu: State<Menu<Wry>>) -> tauri::Result<()> {
    window.popup_menu(&*menu)
}

fn main() {
    tauri::Builder::default()
        .plugin(
            // Restores and saves the position only; size and always-on-top are ours.
            tauri_plugin_window_state::Builder::new()
                .with_state_flags(StateFlags::POSITION)
                .build(),
        )
        .invoke_handler(tauri::generate_handler![show_menu])
        .setup(|app| {
            let path = app.path().app_config_dir()?.join("settings.json");
            let s = load(&path);

            let on_top = CheckMenuItem::with_id(
                app,
                "on_top",
                "Always on Top",
                true,
                s.always_on_top,
                None::<&str>,
            )?;
            let tray = CheckMenuItem::with_id(
                app,
                "tray",
                "Show Tray Icon",
                true,
                s.show_tray_icon,
                None::<&str>,
            )?;
            let quit = MenuItem::with_id(app, "quit", "Quit Nyan Clock", true, None::<&str>)?;
            let menu = Menu::with_items(
                app,
                &[&on_top, &tray, &PredefinedMenuItem::separator(app)?, &quit],
            )?;

            TrayIconBuilder::with_id("main")
                .icon(app.default_window_icon().unwrap().clone())
                .tooltip("Nyan Clock")
                .menu(&menu)
                .build(app)?;
            app.manage(menu);
            apply(app.handle(), s);

            // Check items toggle themselves on click; read their state back.
            app.on_menu_event(move |app, event| match event.id().as_ref() {
                "quit" => {
                    let _ = app.save_window_state(StateFlags::POSITION);
                    app.exit(0);
                }
                "on_top" | "tray" => {
                    let s = Settings {
                        always_on_top: on_top.is_checked().unwrap_or(true),
                        show_tray_icon: tray.is_checked().unwrap_or(true),
                    };
                    apply(app, s);
                    save(&path, s);
                }
                _ => {}
            });
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running Nyan Clock");
}
