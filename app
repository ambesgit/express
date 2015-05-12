var exp=require("express"),
io=require("socket.io"),
util=require("util"),
child=require("child_process"),
fs=require("fs"),
os=require("os"),
multer=require("multer"),
config=require("./config/config.json"),
sockets=[];//this will hold active sockets connected to the socket io
bodyparser=require("body-parser");
//var mkd=require("createDir.js"),
path=require("path");
var app=exp();

app.use(multer());
app.use(bodyparser.json());
app.use(bodyparser.urlencoded({extended:true}))
//connect the current directory of the app with the folder that holds the html files
app.set("views", path.join(__dirname,"views"));
//assign the rendering engine to the app by passing the file extension and the handler module
app.engine("html",require("hogan-express"));
//now update the view engine property of the app by passing the extension of the files
app.set("view engine","html");
//load the image in the public folder
app.use(exp.static(path.join(__dirname, "public")));
//load the image in the child folder of the public
app.use(exp.static(path.join(__dirname, "public/profile")));
//load the css style file from the css folder which is child of chat folder
//by doing so, you avoid writting the ccs folder name in 
//the index.html tags src, href, and links
//Also based on the extension of the file, the static method renders the files
//(it can render files with json, html,png,jpg,gif,js,olg,mp4 extensions by default)
app.use("/",exp.static(path.join(__dirname, "css")));
app.use("/",exp.static(path.join(__dirname, "videos")));
app.use("/",exp.static(path.join(__dirname, "js")));
app.use("/",exp.static(path.join(__dirname, "images")));
app.use("/",exp.static(path.join(__dirname, "models")));


/*

from here on the server will looking for specific matching tasks to apply to the request and respond to client


*/

//load the routing code in the file router and immidately call it
//after manuplating the incoming request by the above functions, now you can route the request to handle it
require(path.join(__dirname,"route/router.js"))(exp,app,path,fs,config);


//------child process to get video data from users and pass it to the child process to process it
app.on('message', function(data){
	var  obj=JSON.parse(data);
	console.log(obj.hello);	
	})


// ----------------the file that holds the routing functionality is loaded by the above requeir function--------//
//set port property yo the app with the value of the port to listen later on
app.set("port",process.env.PORT || 6060);
//this new server will host the express app server
var server=require("http").createServer(app);
//this will create a child server and listens for the parent server
var io=require("socket.io").listen(server);
//this will load the module in the specified path and execute immidiately
require("./socket/socket.js")(io,fs,path,sockets);
//now the parent server will listen on the port accessed from the app object using the get method of app
server.listen(app.get("port"),function(){	

	console.log("server is running");
});
