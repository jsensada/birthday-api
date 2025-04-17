USE birthday;

CREATE TABLE IF NOT EXISTS users (
    username VARCHAR(50) PRIMARY KEY,
    date_of_birth DATE NOT NULL
);

-- Grant access to the table
GRANT ALL ON TABLE users TO birthday;