extern crate fastcgi;

use std::io::Write;
use std::time::SystemTime;

fn main() {
    fastcgi::run(|mut req| {
        write!(
            &mut req.stdout(),
            "Content-Type: text/plain\n\n{:?}",
            SystemTime::now()
        )
        .unwrap_or(());
    });
}
