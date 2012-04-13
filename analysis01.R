library("rmongodb")
setwd("/Users/weidongyang/Projects/Ranalysis")

mongodb <- mongo.create()
print(mongo.get.databases(mongodb))

print(mongo.simple.command(mongodb, "admin", "buildInfo", 1))


db<-"trust_exchange_development"

#find user_id from users collection
ns<-paste(db, "users", sep=".")
buf<-mongo.bson.buffer.create()
mongo.bson.buffer.append(buf, "name", "Weidong Yang")
mongo.bson.buffer.append(buf, "provider", "facebook")
query <-mongo.bson.from.buffer(buf)
wd<-mongo.find.one(mongodb, ns, query)
lwd <- mongo.bson.to.list(result)
userid <-lresult['_id']


#fetch FB profile
ns<-paste(db, "facebook_profiles", sep=".")
buf<-mongo.bson.buffer.create()
oid<-mongo.oid.from.string(as.character(userid$'_id'))
mongo.bson.buffer.append(buf, "user_id", oid)
query<-mongo.bson.from.buffer(buf)
wdfb<-mongo.find.one(mongodb, ns, query)

lwdfb <- mongo.bson.to.list(wdfb)

#mutual_friend_count field is not reliable
friends<-lwdfb$friends
numFriends <-length(friends)

arrFriends <- array(0, c(numFriends))
idx = 1
for(i in 1:numFriends){
	cnt = friends[i]$'1'$mutual_friend_count
	if(is.numeric(cnt)){
		arrFriends[idx]=cnt
		idx=idx+1
	}	
}


edges<-lwdfb$edges
numEdges<-length(edges)/2

arrEdges <-array(0, c(numEdges, 2))
idx=1
for(i in 1:(2*numEdges)){
	uid1 = as.double(edges[[i]][[1]])
	uid2 = as.double(edges[[i]][[2]])
	if(uid2<uid1){
		arrEdges[idx,1] = uid1
		arrEdges[idx,2] = uid2
		idx=idx+1
	}
}

mutualEdges <-as.data.frame(table(arrEdges[]))
freq<-mutualEdges[2][1]$Freq

hist(freq)