import { Router } from "express";
import axios from "axios";

const createActivityRoutes = (isAuthenticated) => {
  const router = Router();
  const API_URL = process.env.API_URL;

  // Get all activities
  router.get("/", isAuthenticated, async (req, res) => {
    try {
      const response = await axios.get(`${API_URL}/activity`);
      // res.json(response.data);

      res.render("user/activity/activityManager.ejs", {
        user: req.user,
        activities: response.data,
        messages: req.flash("messages"),
        title: "Activity Manager",
      });
    } catch (error) {
      res.status(500).json({ error: "Failed to fetch activities" });
    }
  });

  // Get activity by ID
  router.get("/:id", isAuthenticated, async (req, res) => {
    const { id } = req.params;

    const response = await axios.get(`${API_URL}/activities/${id}`);
    // console.table(response.data);
    res.render("user/activity/activityManager.ejs", {
      user: req.user,
      activities: response.data,
      messages: req.flash("messages"),
      title: "Activity Manager",
    });
  });

  // Create a new activity
  router.post("/create", isAuthenticated, async (req, res) => {
    const { name, programs, percentages, status, user_id } = req.body;
    try {
      await axios.put(`${API_URL}/addactivity`, {
        name,
        programs,
        percentages,
        status,
        user_id,
      });
      res.json({ message: "Activity created successfully" });
    } catch (error) {
      res.status(500).json({ error: "Failed to create activity" });
    }
  });

  // Delete an activity
  router.post("/delete", isAuthenticated, async (req, res) => {
    const { id } = req.body;
    try {
      await axios.post(`${API_URL}/deleteactivity`, { id });
      res.json({ message: "Activity deleted successfully" });
    } catch (error) {
      res.status(500).json({ error: "Failed to delete activity" });
    }
  });

  // Edit an activity
  router.put("/edit/:id", isAuthenticated, async (req, res) => {
    const { id } = req.params;
    const { name, programs, percentages, status, user_id } = req.body;
    try {
      await axios.put(`${API_URL}/editactivity/${id}`, {
        name,
        programs,
        percentages,
        status,
        user_id,
      });
      res.json({ message: "Activity edited successfully" });
    } catch (error) {
      res.status(500).json({ error: "Failed to edit activity" });
    }
  });

  return router;
};

export default createActivityRoutes;
