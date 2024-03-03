use totp_rs::{Algorithm, Secret, TOTP};

pub struct OTP {
    pub code: String,
    pub ttl: u64
}

impl OTP {
    pub fn new(secret: &str) -> Result<Self, &'static str> {
        match totp_for(secret_to_vec(secret)?) {
            Ok(totp) => {
                match totp.generate_current() {
                    Ok(token) => Ok(Self {
                        code: token,
                        ttl: totp.ttl().unwrap(),
                    }),
                    Err(_) => Err("Error generating token"),
                }
            }
            Err(_) => Err("Error creating TOTP"),
        }
    }
    pub fn code(&self) -> &str {
        &self.code
    }
    pub fn ttl(&self) -> u64 {
        self.ttl
    }
}

pub fn otp_for(secret: &str) -> Result<String, &'static str> {
    let secret = secret_to_vec(secret)?;
    totp(secret)
}

/// Converts a string to an encoded secret. Must be Base32 encoded.
fn secret_to_vec(secret: &str) -> Result<Vec<u8>, &'static str> {
    match Secret::Encoded(secret.to_string()).to_bytes() {
        Ok(secret) => Ok(resize_secret(secret)),
        Err(_) => Err("Error converting secret to bytes"),
    }
}

/// Resizes the secret to 16 bytes if it is less than 16 bytes.
fn resize_secret(secret: Vec<u8>) -> Vec<u8> {
    if secret.len() >= 16 {
        return secret;
    }
    let mut secret = secret;
    secret.resize(16, 0);
    secret
}

fn totp_for(secret: Vec<u8>) -> Result<TOTP, &'static str> {
    match TOTP::new(
        Algorithm::SHA1,
        6,
        1,
        30,
        secret,
    ) {
        Ok(totp) => Ok(totp),
        Err(_) => Err("Error creating TOTP"),
    }
}

/// Generates a TOTP token from a secret that is in byte form.
fn totp(secret: Vec<u8>) -> Result<String, &'static str> {
    match totp_for(secret) {
        Ok(totp) => {
            match totp.generate_current() {
                Ok(token) => Ok(token),
                Err(_) => Err("Error generating token"),
            }
        }
        Err(_) => Err("Error creating TOTP"),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_resize_small() {
        let secret = vec![1; 15];
        assert_eq!(secret.len(), 15);
        let secret = resize_secret(secret);
        assert_eq!(secret.len(), 16);
    }

    #[test]
    fn test_resize_same() {
        let secret = vec![1; 16];
        assert_eq!(secret.len(), 16);
        let secret2 = resize_secret(secret.clone());
        assert_eq!(secret2.len(), 16);
        assert_eq!(secret, secret2);
    }

    #[test]
    fn test_resize_large() {
        let secret = vec![1; 17];
        assert_eq!(secret.len(), 17);
        let secret2 = resize_secret(secret.clone());
        assert_eq!(secret2.len(), 17);
        assert_eq!(secret, secret2);
    }
}
