export interface Env {
  DB: D1Database;
}

import { handleReportRoutes } from "./routes/reportRoutes";

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const pathParts = url.pathname.split("/").filter(Boolean);

    const corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: corsHeaders });
    }

    try {

      // 📍 Stations list
      if (pathParts[0] === "stations" && pathParts.length === 1) {
        const limit = parseInt(url.searchParams.get("limit") || "20");
        const offset = parseInt(url.searchParams.get("offset") || "0");

        const { results } = await env.DB.prepare(
          "SELECT * FROM stations ORDER BY updatedAt DESC LIMIT ? OFFSET ?"
        ).bind(limit, offset).all();

        return Response.json(results, { headers: corsHeaders });
      }

      if(pathParts[0]==="feedback" && request.method === "POST"){
        const body :any = await request.json();

        if(!body.feedback || !body.category){
          return new Response("Missing fields", {status:400, headers:corsHeaders});
        }

        await env.DB.prepare(`
        INSERT INTO feedback (id, category, content, createdAt)
        VALUES (?, ?, ?, ?)
        `).bind(
          crypto.randomUUID(),
          body.category,
          body.feedback,
          Date.now()
        ).run();

        return Response.json({success:true, message:"Feedback saved"}, {headers:corsHeaders});
      }

      // 📍 Single station
      if (pathParts[0] === "stations" && pathParts.length === 2) {
        const stationId = pathParts[1];

        const result = await env.DB.prepare(
          "SELECT * FROM stations WHERE stationId = ?"
        ).bind(stationId).first();

        if (!result) {
          return new Response("Not Found", { status: 404, headers: corsHeaders });
        }

        return Response.json(result, { headers: corsHeaders });
      }

      // 📍 Report routes (Station Reports)
      if (pathParts[0] === "stations" && pathParts[2] === "reports") {
        return handleReportRoutes(request, env, pathParts, corsHeaders);
      }

      // 📍 User Reports (My Reports)
      if (pathParts[0] === "users" && pathParts[2] === "reports") {
        const userId = pathParts[1];
        if (request.method === "GET") {
          const { results } = await env.DB.prepare(
            "SELECT * FROM reports WHERE userId = ? ORDER BY createdAt DESC"
          ).bind(userId).all();
          return Response.json(results, { headers: corsHeaders });
        }
      }

      // 📍 Delete Report
      if (pathParts[0] === "reports" && pathParts.length === 2) {
        const reportId = pathParts[1];
        if (request.method === "DELETE") {
          await env.DB.prepare("DELETE FROM reports WHERE id = ?").bind(reportId).run();
          return Response.json({ success: true, message: "Report deleted" }, { headers: corsHeaders });
        }
      }

      // 📍 Verifications
      if (pathParts[0] === "verifications") {
        if (request.method === "POST") {
          const body: any = await request.json();

          // Check if already exists
          const existing = await env.DB.prepare(
            "SELECT * FROM verification_requests WHERE userId = ? LIMIT 1"
          ).bind(body.userId).first();

          if (existing) {
            return Response.json({ success: false, message: "Verification request already exists" }, { status: 400, headers: corsHeaders });
          }

          await env.DB.prepare(`
               INSERT INTO verification_requests 
               (id, userId, fullName, stationId, stationName, contact, role, status, createdAt) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            `).bind(
            crypto.randomUUID(),
            body.userId,
            body.fullName,
            body.stationId,
            body.stationName,
            body.contact,
            body.role,
            'pending',
            Date.now()
          ).run();
          return Response.json({ success: true, message: "Verification submitted" }, { headers: corsHeaders });
        }
      }

      // 📍 Handle Feedback Submission
      if (pathParts[0] === "feedback" && request.method === "POST") {
        const body: any = await request.json();

        if (!body.feedback || !body.category) {
          return new Response("Missing fields", { status: 400, headers: corsHeaders });
        }

        await env.DB.prepare(`
    INSERT INTO feedback (id, category, content, createdAt) 
    VALUES (?, ?, ?, ?)
  `).bind(
          crypto.randomUUID(),
          body.category,
          body.feedback,
          Date.now()
        ).run();

        return Response.json({ success: true, message: "Feedback saved" }, { headers: corsHeaders });
      }

      // 📍 User Verification Check
      if (pathParts[0] === "users" && pathParts[2] === "verification") {
        const userId = pathParts[1];
        if (request.method === "GET") {
          const result = await env.DB.prepare(
            "SELECT * FROM verification_requests WHERE userId = ? LIMIT 1"
          ).bind(userId).first();

          if (!result) return Response.json(null, { headers: corsHeaders });
          return Response.json(result, { headers: corsHeaders });
        }
      }

      return new Response("QuickCNG API is Online", { headers: corsHeaders });

    } catch (e: any) {
      return new Response(e.message, { status: 500, headers: corsHeaders });
    }
  },
};