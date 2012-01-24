var GithubPinboard = function(user, repo, containerId) {                                             
  GithubPinboard.containerId = containerId || "githubPinboard";                                      
  var script = document.createElement("script");                                                     
  script.setAttribute("src", "https://api.github.com/repos/" + user + "/" + repo + "/contributors?callback=GithubPinboard.parse");                                                                        

  var stylesheet = document.createElement("link");                                                   
  stylesheet.setAttribute("rel", "stylesheet");
  stylesheet.setAttribute("href", "githubpinboard.css");                                             
  stylesheet.setAttribute("type", "text/css");
  stylesheet.setAttribute("media", "screen");
  
  var head = document.getElementsByTagName("head")[0];                                               
  head.appendChild(script);
  head.insertBefore(stylesheet, head.firstChild);
} 

GithubPinboard.parse = function(response) {                                                          
  var meta = response["meta"];
  if (meta["status"] != 200) {                                                                       
    var error = meta["status"] + " " + response["data"]["message"];                                  
    throw "<GithubPinboard> Error fetching repository: " + error;
  } 
  
  var contributors = response["data"];                                                               
  var pinboard = document.createElement("div");                                                      
  contributors.forEach( function(contributor) {                                                      
    var login = contributor["login"];
    var avatar = contributor["avatar_url"];                                                          
    var imagemapName = "githubpinboard-imagemap-" + login;                                          
    
    var imagemap = document.createElement("map");                                                    
    imagemap.setAttribute("name", imagemapName);
    pinboard.appendChild(imagemap);
    
    var area = document.createElement("area");                                                       
    area.setAttribute("shape", "circle");
    area.setAttribute("coords", "25 25 25");                                                         
    area.setAttribute("href", "http://github.com/" + login);                                         
    imagemap.appendChild(area);
    
    var img = document.createElement("img");                                                         
    img.setAttribute("usemap", "#" + imagemapName);                                                        
    img.setAttribute("class", "githubpinboard-circle");                                              
    img.setAttribute("alt", login);
    img.setAttribute("src", avatar);                                                                 
    pinboard.appendChild(img);
  }); 
  
  document.getElementById(GithubPinboard.containerId).appendChild(pinboard);                         
} 
