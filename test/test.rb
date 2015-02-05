require 'digest/md5'
require 'json'
require 'httparty'


data={:OrderId=>'11232', :GameId=>'11', :ServerId=>'127.0.0.1:4567' ,:Uid=>'293' , :Amount=>'25', :CallBackInfo=>'index=1', :OrderStatus=>'S',:Time=>'30'}
infos = {headers: {'content-type'=>'application/json; charset=utf-8'}, query: data}
resp = HTTParty.get("http://127.0.0.1:3000/app/gb_verify_pay", infos)
puts resp