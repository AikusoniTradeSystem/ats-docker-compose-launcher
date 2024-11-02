-- ./initdb/init.sql

CREATE TABLE IF NOT EXISTS USERS
(
    USERNAME VARCHAR(50) NOT NULL PRIMARY KEY,
    PASSWORD VARCHAR(256) NOT NULL
);

CREATE TABLE IF NOT EXISTS USER_ROLE
(
    USERNAME VARCHAR(50) NOT NULL,
    ROLENAME VARCHAR(50) NOT NULL,
    PRIMARY KEY (USERNAME, ROLENAME)
);

INSERT INTO USERS (USERNAME, PASSWORD)
VALUES ('admin', '{bcrypt}$2a$10$G91Biiz2qomu/feju3BFNOyeM1hfrrdsARWW00hXi0SKPEMPLmKfW'), -- password is password123!
       ('user1', '{bcrypt}$2a$10$G91Biiz2qomu/feju3BFNOyeM1hfrrdsARWW00hXi0SKPEMPLmKfW'), -- password is password123!
       ('user2', '{bcrypt}$2a$10$G91Biiz2qomu/feju3BFNOyeM1hfrrdsARWW00hXi0SKPEMPLmKfW') -- password is password123!
ON CONFLICT (USERNAME) DO NOTHING;

INSERT INTO USER_ROLE (USERNAME, ROLENAME)
VALUES ('admin', 'admin'),
       ('admin', 'item-registration'),
       ('user1', 'item-sell'),
       ('user1', 'item-buy'),
       ('user1', 'item-stat'),
       ('user2', 'item-sell'),
       ('user2', 'item-buy'),
       ('user2', 'item-stat')
ON CONFLICT (USERNAME, ROLENAME) DO NOTHING;
