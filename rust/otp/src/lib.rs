use totp_rs::{Algorithm, Secret, TOTP};

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

/// Generates a TOTP token from a secret that is in byte form.
fn totp(secret: Vec<u8>) -> Result<String, &'static str> {
    match TOTP::new(
        Algorithm::SHA1,
        6,
        1,
        30,
        secret,
    ) {
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
