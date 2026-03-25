-- 1. Stations Table
-- Aligned with Worker UPDATE logic: isAvailable, currentTraffic, updatedAt
CREATE TABLE IF NOT EXISTS stations (
    stationId TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    provider TEXT,
    address TEXT,
    city TEXT,
    district TEXT,
    state TEXT,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    isAvailable INTEGER DEFAULT 1,    -- 1 = Available, 0 = Not Available
    currentTraffic TEXT DEFAULT 'normal',
    is24Hours INTEGER DEFAULT 0,      -- 1 = Yes, 0 = No
    confidence INTEGER DEFAULT 0,
    reportCount INTEGER DEFAULT 0,
    freshnessMinutes INTEGER,
    updatedAt INTEGER                 -- Storing Date.now() as Integer
);

-- 2. Reports Table
CREATE TABLE IF NOT EXISTS reports (
    id TEXT PRIMARY KEY,
    stationId TEXT NOT NULL,
    stationName TEXT,
    traffic TEXT,
    isAvailable INTEGER,
    userId TEXT,
    userName TEXT,
    userRole TEXT,
    createdAt INTEGER
);

-- 3. Feedback Table
CREATE TABLE IF NOT EXISTS feedback (
    id TEXT PRIMARY KEY,
    category TEXT NOT NULL,
    content TEXT NOT NULL,
    createdAt INTEGER NOT NULL
);

-- 4. Verification Requests Table
-- (Needed for the 'verifications' route in your index.ts)
CREATE TABLE IF NOT EXISTS verification_requests (
    id TEXT PRIMARY KEY,
    userId TEXT NOT NULL,
    fullName TEXT,
    stationId TEXT,
    stationName TEXT,
    contact TEXT,
    role TEXT,
    status TEXT DEFAULT 'pending',
    createdAt INTEGER NOT NULL
);