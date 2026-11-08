// set up an HTTP server off port 3000
const express = require("express");
const app = express();
const port = 3000;

//******************************************************************************
//*** set up mysql connections
//******************************************************************************
const pool = require('./mysql');

//*** server waits indefinitely for incoming requests
app.listen(port, function () {
    console.log("NodeJS app listening on port " + port);
});

//******************************************************************************
//*** receive the get request 
//******************************************************************************
app.get("/", async (req, res) => {
    //*** extract the search and format parameters from the query string
    const category = req.query.category;
    const author = req.query.author;
    const format = req.query.format;

    let sql_query = "SELECT * FROM books";
    const params = [];

    if (category) {
        sql_query += " WHERE category = ?";
        params.push(category);
    } else if (author) {
        sql_query += " WHERE author = ?";
        params.push(author);
    }

    try {
        //*** pool.execute returns [rows, fields]
        const [result, fields] = await pool.execute(sql_query, params);

        if (format === "text") {
            let html_body = "<HTML><HEAD><META CHARSET='UTF-8'></HEAD>";
            html_body += "<STYLE>body{font-family:arial}</STYLE>";
            html_body += "<BODY><TABLE BORDER=1>";

            //*** print column headings
            html_body += "<TR>";
            for (let i = 0; i < fields.length; i++) {
                html_body += (`<TH>${fields[i].name.toUpperCase()}</TH>`);
            }
            html_body += "</TR>";

            //*** print rows of table data
            for (let i = 0; i < result.length; i++) {
                html_body += (`<TR><TD>${result[i].bookid}</TD>` +
                              `<TD>${result[i].title}</TD>` +
                              `<TD>${result[i].author}</TD>` +
                              `<TD>${result[i].category}</TD>` +
                              `<TD>${result[i].price}</TD></TR>`);
            }

            html_body += "</TABLE></BODY></HTML>";
            res.send(html_body);
        } else {
            //*** JSON is the default when format is missing or anything else
            res.json(result);
        }

    } catch (err) {
        //*** log the detailed error on the server
        console.error("SQL Error:", err);
        res.status(500).send("<html><body><h1>Database Query Error</h1><p>An error occurred while fetching data.</p></body></html>");
    }
});
