use std::path::PathBuf;

use anyhow::{anyhow, Result};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, clap::ValueEnum)]
pub enum Windows {
    #[clap(name = "tldraw")]
    TlDraw,
}

pub async fn open_windows(handle: &tauri::AppHandle, windows: &Vec<Windows>) -> Result<()> {
    for window in windows {
        let handle = handle.clone();
        let window_str = match window {
            Windows::TlDraw => "tldraw",
        };

        let window_path: PathBuf = format!("windows/{}", window_str).into();

        // TODO: this maybe should be in seperate threads.
        let built_window = tauri::WebviewWindowBuilder::new(
            &handle,
            window_str,
            tauri::WebviewUrl::App(window_path.clone()),
        )
        .build();

        if let Err(e) = built_window {
            return Err(anyhow!(
                "failed to build window {} (path {}): {}",
                window_str,
                window_path.display(),
                e
            ));
        }
    }

    Ok(())
}
