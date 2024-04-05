import { Router } from "express";
import axios from "axios";

const createLocationRoutes = (isAuthenticated) => {
  const router = Router();
  const API_URL = process.env.API_URL;

  router.get("/", isAuthenticated, async (req, res) => {
    const locationResponse = await axios.get(`${API_URL}/location`);
    const location = locationResponse.data; // Extract the data from the Axios response

    res.render("user/location/locationManager.ejs", {
      user: req.user,
      location: location,
      messages: req.flash("messages"),
      title: "Location Manager",
    });
  });

  router.post("/delete", isAuthenticated, async (req, res) => {
    const { locationId } = req.body;

    try {
      await axios.post(`${API_URL}/deletelocation/`, { locationId });
      res.redirect("/locationManager");
    } catch (error) {
      console.error("Error deleting location:", error);
      res
        .status(500)
        .json({ success: false, error: "Error deleting location" });
    }
  });

  router.post("/edit/:id", isAuthenticated, async (req, res) => {
    const locationId = req.params.id;
    const { locationName, locationRole, location_id } = req.body;

    const location_role = locationRole != "" ? locationRole : null;

    try {
      await axios.put(`${API_URL}/editlocation/${locationId}`, {
        locationName,
        location_role,
        location_id,
      });

      res.redirect("/locationManager");
    } catch (error) {
      console.error("Error updating location:", error);
      res
        .status(500)
        .json({ success: false, error: "Error updating location" });
    }
  });

  router.post("/add", isAuthenticated, async (req, res) => {
    const { locationName, locationRole, location_id } = req.body;

    const location_role = locationRole != "" ? locationRole : null;

    try {
      await axios.put(`${API_URL}/addlocation`, {
        locationName,
        location_role,
        location_id,
      });

      res.redirect("/locationManager");
    } catch (error) {
      console.error("Error adding location:", error);
      res.status(500).json({ success: false, error: error });
    }
  });

  return router;
};

export default createLocationRoutes;
