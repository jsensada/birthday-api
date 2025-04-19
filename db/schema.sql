USE birthday;

CREATE TABLE IF NOT EXISTS users (
    username VARCHAR(50) PRIMARY KEY,
    date_of_birth DATE NOT NULL
);

-- Insert sample data
INSERT INTO users (username, date_of_birth) VALUES
('foo', '1994-11-18'),
('bar', '2025-04-12');


-- Grant access to the table
GRANT ALL ON TABLE users TO birthday;