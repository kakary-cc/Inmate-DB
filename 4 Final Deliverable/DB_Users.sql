USE jail;

CREATE TABLE DB_Users (
    U_ID DECIMAL(6),
    Email VARCHAR(30) NOT NULL UNIQUE,
    Password VARCHAR(100) NOT NULL,
    Status CHAR(1) DEFAULT 'V', -- V: Verified, S: Suspended
    PRIMARY KEY(U_ID)
);

INSERT INTO DB_Users VALUES
(100001, 'admin@example.com', 'BakaTest', 'V');

SELECT * FROM DB_Users
WHERE Email LIKE "admin@example.com";

INSERT INTO DB_Users VALUES
(0219, 'admin@1.com', '$argon2id$v=19$m=65536,t=3,p=4$QWfbzwQq2BkII6adKt4ANQ$nvP284FPw1FZa47Zx3gw+TNmqsYE9s4iKmhdl3nO+qM');