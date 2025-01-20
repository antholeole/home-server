use clap::Parser;
use cli::Cli;
use log::LevelFilter;
use tauri::{async_runtime::block_on, AppHandle};
use tauri_plugin_log::{Target, TargetKind};
use windows::open_windows;

mod cli;
mod windows;

fn setup(handle: AppHandle, args: Cli) -> Result<(), Box<dyn std::error::Error>> {
    let task =
        tauri::async_runtime::spawn(async move { open_windows(&handle, &args.windows).await });

    Ok(block_on(task).map_err(|e| Box::new(e))??)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let args = Cli::parse();

    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .plugin(
            tauri_plugin_log::Builder::new()
                .clear_targets()
                .targets([
                    Target::new(TargetKind::Stdout),
                    Target::new(TargetKind::Webview),
                ])
                .level(LevelFilter::max())
                .build(),
        )
        .setup(move |app| setup(app.handle().clone(), args))
        .run(tauri::generate_context!("tauri.conf.json"))
        .expect("error while running tauri application");
}
