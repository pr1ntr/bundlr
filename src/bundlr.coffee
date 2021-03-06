

path = require('path')
coffeeify = require('coffeeify')
browserify = require('browserify')
uglify = require('uglify-js')
mime = require('mime')
through = require('through')
fs = require('fs')
typeify = require('typeify')
htmlr = require('browserify-htmlr')


module.exports = bundlr = (opts) ->
    
    src = opts.src
    route = opts.route
    dest = opts.dest
    debug = opts.debug
    write = opts.write or true
    caching = opts.cache or false
    
    
    b = browserify() 
    
    b.transform(coffeeify)  
    b.transform(typeify)
    b.transform(htmlr)

    b.transform (filename) ->
        b.allFiles.push(filename)
        return through()

       


    b.add src
    


    
    
   
    cache = {}

         

 
    

    return (req, res, next) ->




        sendResponse = (err, src) ->
            if err
                next(err)
            else
                

                res.contentType('application/javascript')
                res.send(src)
        generate = (b , callback) ->
            
            try
                b.allFiles = []
                b.bundle {debug:debug} , (err, src) ->
                    compress = !debug
                              

                    if err
                        return callback(err)


                    if compress
                        result = uglify.minify src ,
                            fromString:true

                        src = result.code

                    cache[req_path] = src

                    
                    


                    if write
                        fs.writeFile dest , src, 'utf8', ->
                            console.log "File Written."

                    callback(null,src)

            catch err

                return callback(err)
            
            

            


        req_path = req.path



        if !path.extname(req_path)
            return next()
        else if mime.lookup(req_path) isnt "application/javascript"
            return next()


        if req_path is route   
            if caching and cache[req_path] isnt undefined
                sendResponse(null, cache[req_path])
            else
                generate(b , sendResponse)
        else
            next()