USE jail;

-- V: Verified, S: Suspended
CREATE TABLE Users (
    Email VARCHAR(30),
    Passwd VARCHAR(100) NOT NULL,
    Status CHAR(1) DEFAULT 'V',
    PRIMARY KEY(Email)
);

INSERT INTO Users (Email, Passwd) VALUES
('admin@example.com', '$argon2id$v=19$m=65536,t=3,p=4$QWfbzwQq2BkII6adKt4ANQ$nvP284FPw1FZa47Zx3gw+TNmqsYE9s4iKmhdl3nO+qM');

SELECT * FROM Users
WHERE Email LIKE "admin@example.com";