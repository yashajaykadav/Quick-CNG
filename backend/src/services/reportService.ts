export async function getStationReports(DB: D1Database, stationId: string) {
    const { results } = await DB.prepare(`
    SELECT *
    FROM reports
    WHERE stationId = ?
    ORDER BY createdAt DESC
    LIMIT 20
  `)
        .bind(stationId)
        .all();

    return results || [];
}

export async function createReport(
    DB: D1Database,
    stationId: string,
    body: any
) {
    // 1. Prepare values to match your specific schema types
    const now = new Date().toISOString(); // Matches DATETIME format
    const statusValue = body.isAvailable ? 'available' : 'unavailable'; // Matches 'status' TEXT
    const trafficValue = body.traffic ?? 'low'; // Matches 'traffic' TEXT

    try {
        // 2. Insert into reports (History)
        const insertReport = DB.prepare(`
            INSERT INTO reports (id, stationId, stationName, traffic, isAvailable, userId, userName, userRole, createdAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `).bind(
            crypto.randomUUID(),
            stationId,
            body.stationName ?? "Unknown",
            trafficValue,
            body.isAvailable ? 1 : 0,
            body.userId ?? "anonymous",
            body.userName ?? "User",
            body.userRole ?? "user",
            Date.now()
        );

        // 3. Update Stations (Matching your EXACT schema columns)
        const updateStation = DB.prepare(`
            UPDATE stations 
            SET status = ?, 
                traffic = ?, 
                updatedAt = ? 
            WHERE stationId = ?
        `).bind(
            statusValue,    // Sets 'available' or 'unavailable'
            trafficValue,   // Sets 'low', 'medium', etc.
            now,            // Sets ISO String for DATETIME
            stationId
        );

        // Execute batch
        await DB.batch([insertReport, updateStation]);

    } catch (error: any) {
        console.error("D1 Error:", error.message);
        throw new Error(`Database error: ${error.message}`);
    }
}