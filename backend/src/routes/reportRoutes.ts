import { createReport, getStationReports } from "../services/reportService";

export async function handleReportRoutes(
  request: Request,
  env: any,
  pathParts: string[],
  corsHeaders: any
): Promise<Response> {

  const stationId = pathParts[1];

  // 📍 GET /stations/:id/reports
  if (request.method === "GET") {

    const reports = await getStationReports(env.DB, stationId);

    return Response.json(reports, { headers: corsHeaders });
  }

  // 📍 POST /stations/:id/reports
  if (request.method === "POST") {

    const body = await request.json();

    await createReport(env.DB, stationId, body);

    return Response.json(
      { success: true, message: "Report submitted" },
      { headers: corsHeaders }
    );
  }

  return new Response("Method Not Allowed", { status: 405, headers: corsHeaders });
}