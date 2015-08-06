require 'sinatra'
require 'shotgun'

=begin
spm = sum per month
cpm = commission per month
_w_o_ = without
_w_ = with
=end
class Calc 

def totalsum(spm,month,firstpaym,firstcommis) # Общая сумма
totalsum = spm*month + firstpaym+firstcommis
end
def overpayment(sum, total) #Переплата
overpayment = total - sum
end
def sum_w_o_1st_paym(sum,firstpaym) #Сума без первой выплаты
sum_w_o = sum - firstpaym
end
def com_per_month(sum,commis) #Комиссия за месяц
cpm = sum*commis
end
end

class ASPC < Calc #Аннуитетная схема погашения кредита
 
def spm(sum,proc,month,cpm) #Сумма за месяц
a=1+proc/1200
k=a**month*(a-1)/(a**month - 1)
spm = k*sum
fspm = spm+cpm
end


end
class DSPC < Calc #Дифференцированная схема погашения кредита

def maxspm(sum,month,proc) #Максимальная сумма платежа за месяц
f = sum/month
proc1 = (sum-f*(1-1))*proc/1200 # проценты за 1 месяц (максимальный)
maxspm = f+proc1 # Сумма
end 
def creditusage(month,proc) # Плата за пользование кредитом, %
creditusage = proc*(month+1)/24
end
end


get '/' do
erb :main
end 

post '/result' do
  calc = Calc.new
  ann = ASPC.new
  diff = DSPC.new
  
  @sum = params[:sum].to_i
  @proc = params[:proc].to_f
  @month = params[:month].to_i
  if params[:onetimefee] == "1" then 
  @firstpaym = ((params[:firstpaym].to_f)/100)*@sum
  else
  @firstpaym = params[:firstpaym].to_f
  end
  if params[:onetimecom] == "1" then
  @firstcommis = ((params[:firstcommis].to_f)/100)*@sum
  else
  @firstcommis = params[:firstcommis].to_f
  end
  @commis = params[:commis].to_f
  
  
  @@start = calc.sum_w_o_1st_paym(@sum,@firstpaym) #сумма без первого взноса
  @@cpm = calc.com_per_month(@@start, @commis)
  if params[:scheme] == "1" then #Аннуитетная
      @annspm = ann.spm(@@start,@proc,@month,@@cpm)#сумма за месяц
      @annover = ann.overpayment(@sum, ann.totalsum(@annspm,@month,@firstpaym,@firstcommis)) #переплата по кредиту
      erb :annuit
  else  #Дифференцированная
      @diffmaxspm = diff.maxspm(@@start,@month,@proc) #сумма за месяц
    @diffcu = diff.creditusage(@month,@proc) #процент за пользование кредитом
      @diffover = (@diffcu/100+@commis)*@@start+@firstcommis #переплата по кредиту
      erb :stand
   end
  end