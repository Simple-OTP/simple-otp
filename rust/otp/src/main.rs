use std::env;
use otp::{OTP};

fn main() {

    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Usage: {} <secret>", args[0]);
        return;
    }

    let otp = OTP::new(&args[1]).unwrap();

    println!("{}: secs left {}", otp.code(), otp.ttl());
}