use clap::Parser;

#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
pub struct Cli {
    #[clap(long, value_delimiter = ' ', num_args = 0..)]
    pub windows: Vec<crate::windows::Windows>,
}
