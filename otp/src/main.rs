use std::time::SystemTime;
use totp_rs::{Algorithm, TOTP, Secret};
use std::env;

fn main() {

    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Usage: {} <secret>", args[0]);
        return;
    }

    let time = SystemTime::now().duration_since(SystemTime::UNIX_EPOCH).unwrap().as_secs();

    let mut secret = Secret::Encoded(args[1].to_string()).to_bytes().unwrap();
    if secret.len()<16 {
        secret.resize(16, 0);
    }
    println!("length: {}", secret.len());
    let totp = TOTP::new(
        Algorithm::SHA1,
        6,
        1,
        30,
        secret,
    ).unwrap();
    let token = totp.generate_current().unwrap();
    println!("{} : {}", token, time % 30);
}