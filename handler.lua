-- vim: sw=4 ts=4
require "class"
require "http-request"
require "responder"
require "http-error"


Handler=class(function(handler,socket)
	console.log("http handler connection opened")
	handler.socket=socket
	handler.payload=""
	handler.package=0
	handler.header=false
	handler.bytesReceived=0

	handler.socket:on("receive", function(socket,data)
		console.debug("tcp package received")
		console.debug("data: "..tostring(data), 7)
		if not handler.header then
			handler.payload=handler.payload..data
			handler.header, handler.payload=httpreq.parseHeader(handler.payload)
		else
			handler.payload=data
			collectgarbage()
		end
		if handler.header then
			console.debug("body is: "..tostring(handler.payload),10)
			handler.bytesReceived=handler.bytesReceived+#handler.payload
			handler.package=handler.package+1
			console.debug("bytesReceived: "..tostring(handler.bytesReceived))

			local k,v = next(httpreq.responder)
			while k and not v.respond(handler.header, socket, handler) do
				k, v = next(httpreq.responder, k)
			end

--			if not handler.header.contentLength or handler.bytesReceived>=handler.header.contentLength then
--				socket:close()
--			end
		end
	end)

	handler.socket:on("disconnection", function(socket)
		handler=nil
		collectgarbage()
		console.log("http handler connection closed")
	end)
end)


console.moduleLoaded("handler")
