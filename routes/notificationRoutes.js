import { Router } from "express";
import axios, { all } from "axios";

const createNotificaitonRoute = (isAuthenticated) => {
    const router = Router();
    const API_URL = process.env.API_URL;

    router.get("/", isAuthenticated,  async (req, res) => {

        res.render("notification.ejs", {
            user: req.user,
                messages: req.flash(""),
                title: "Notification",
        })
    })

    return router
}

export default createNotificaitonRoute