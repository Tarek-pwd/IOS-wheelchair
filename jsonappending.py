
import json


init_string_list=[]

final_string_list=[]


# def clean_string(string):
#     fake_str=''
#     cleaned=[]
    
#     first_idx=0
#     last_idx=len(string)-1
#     exclude_list=[first_idx,last_idx]
    
#     for i in range(len(string)):
#         if i not in exclude_list:
#             elem=string[i]
#             cleaned.append(elem)
            
#     for i in cleaned:
#         fake_str=fake_str+i
            


    
#     return fake_str

import os
flg=1
def conv_tostring(dicti,flg):
    
    bolbol=str(dicti)
    
    if flg==1:
        bolbol=bolbol +','
        
    bolbol=bolbol.replace("'","\"")
    print(bolbol)
    return bolbol
    
    
write_file='Desktop/StairRampFinal/Stair_ramp_final.json' 



path='Desktop/StairRampFinal/'
###Appending all json files as strings in a list>>
for x,y,filenames in os.walk(path):
    for name in filenames:
        if name.endswith('.json'):
            my_file=path+name
            print('file is::',my_file)
            with open(my_file) as my_json_file:
                data=json.load(my_json_file)
                data=data[0]
                init_string_list.append(data)
        
for idx,elem in enumerate(init_string_list):
    
    if idx==len(init_string_list)-1:
        flg=0
    else:
        flg=1
    
    
    final=conv_tostring(elem,flg)
    
    final_string_list.append(final)
    
with open(write_file,'w') as write_f:
    
    write_f.write('[')
    
    for string in final_string_list:
        
        write_f.write(string)
    write_f.write(']')
        
        
 
        

    









    





    

    
    


        
    
    



