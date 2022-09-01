import osmnx as ox
import networkx as nx
import plotly.graph_objects as go
import numpy as np
from queue import PriorityQueue
from plotly.offline import download_plotlyjs, init_notebook_mode,  plot
from plotly.graph_objs import *
import plotly.express as px
import requests as req
import pandas as pd




api_token='pk.eyJ1IjoidGFyZWstMjIiLCJhIjoiY2w3ZHV5dW9zMXF4eTN3bmdtcHZhOGxnZiJ9.Wyi_ekkyK3tm8I9wLDXBKg'
city = ox.geocode_to_gdf('London,UK')
#ax = ox.project_gdf(city).plot(fc='gray', ec='none')

# Defining the map boundaries 
##north, east, south, west = 33.798, -84.378, 33.763, -84.422  

##north, east, south, west=51.500251774305966, -0.1786207550412766,51.49698025856421, -0.16928100920228095
north, east, south, west=51.5142597365802, -0.19836234391315816,51.49187480421723, -0.1587164786407474
# Downloading the map as a graph object 
G = ox.graph_from_bbox(north, south, east, west, network_type = 'walk')  
# Plotting the map graph 
ox.plot_graph(G)

node_list=list(G.nodes)
node_list_data=list(G.nodes(data=True))
edge_list=list(G.edges(data=True)) 

number_nodes=len(node_list)


edges_final=np.zeros((number_nodes,number_nodes))


# for i in range(number_nodes):
#     for j in range(number_nodes):
#         edges_final[i][j]=-1   

# node_name_dict={} 
# for i in range(number_nodes):
#    node_val=node_list[i]
#    node_name_dict[node_val]=i 


# for edge in edge_list:
    
#     first_node=edge[0]
#     second_node=edge[1]
#     row=node_name_dict[first_node]
#     column=node_name_dict[second_node]
    
#     edge_length=edge[2]['length']
#     edges_final[row][column]=edge_length
#     edges_final[column][row]=edge_length


# u=0
# count=0

# for edge in edge_list:
#     count=0
#     n1= edge[0]
#     n2=edge[1]
    
#     bolbol=(n1,n2)
    
#     for edge2 in edge_list:
#         n3= edge2[0]
#         n4=edge2[1]
#         bolbol2=(n3,n4)
        
#         if n1==n3 and n2==n4:
#             count+=1
            
#     print(count)
#     if count>1: 
#         u+=1
#         print('REPETTIONNNNNNNNNNNNNNNNN')
        
    
    
    
    
####INITILIZING EDGES MATRIX==-1

class Graph:
    
    def __init__(self,node_list,edge_list):
        
        self.num_vertices=len(node_list)
        self.edge_list=edge_list
        
        self.node_name_dict={}
        
        for i in range(self.num_vertices):
           node_val=node_list[i]
           self.node_name_dict[node_val]=i 
        print('node dictionary >>',self.node_name_dict)
        
        
        self.visited=[]
         
        
        self.edges_matrix=np.zeros([self.num_vertices,self.num_vertices])
        
        for i in range(self.num_vertices):
            for j in range(self.num_vertices):
                self.edges_matrix[i][j]=-1
                
        print("the edges matrix is::",self.edges_matrix)
        
        
        ##creating the edges matrix from the edges list
        for edge in self.edge_list:
            
            first_node=edge[0]
            second_node=edge[1]
            row=self.node_name_dict[first_node]
            column=self.node_name_dict[second_node]
            
            edge_length=edge[2]['length']
            self.edges_matrix[row][column]=edge_length
            self.edges_matrix[column][row]=edge_length
            
        for i in range(self.num_vertices):
            for j in range(self.num_vertices):
                edges_final[i][j]=self.edges_matrix[i][j]
            
        
            
        self.path_dict={}
        for i in range(self.num_vertices):
            self.path_dict[i]=0
        
        print('path dict',self.path_dict)

             

    

    def set_edges(self,node1,node2,weight):
        
        n1=self.node_name_dict[node1]
        n2=self.node_name_dict[node2]
        
        self.edges_matrix[n1][n2]=weight
        self.edges_matrix[n2][n1]=weight
        
        
    def set_infected_node(self,node):
        
        node_idx=self.node_name_dict[node]
        
        for i in range(self.num_vertices):
            self.edges_matrix[node_idx][i]=float('inf')
            self.edges_matrix[i][node_idx]=float('inf')
            
            
        
    def get_edges(self):
        return self.edges_matrix
    



def Djisktra(graph,starting_node):
    
    graph.path_dict[starting_node]=0
    
    my_dict={}
    for i in range(graph.num_vertices):
        
        if i==starting_node:
            my_dict[i]=0
        else:
            my_dict[i]=float('inf')
            
    print('dictionary:',my_dict)
    
    
    pq=PriorityQueue()
    Edges=graph.get_edges()
    print('y',Edges)
    
    pq.put((0,starting_node))
    
    while pq.empty()==False:
        
        dist_to_node,node=pq.get()
        
        
        graph.visited.append(node)
        
        for elem in range(graph.num_vertices):
            if Edges[node][elem]!=-1:
                weight=Edges[node][elem] 
                print(f'node {node} connected to node {elem} with weight {weight}')
                
                if elem not in graph.visited:
                    old_cost=my_dict[elem]
                    new_cost=weight+my_dict[node]
                    
                    if new_cost<old_cost:
                        my_dict[elem]=new_cost
                        graph.path_dict[elem]=node
                        pq.put((new_cost,elem))
                        
         
   
  
    # cnt=0
    path_list=[]
    final=[]
        
    path_to_target=get_path_to_node(graph.path_dict,starting_node,target,path_list)
    
    
    if len(path_to_target)==1:
        
        path_to_target=path_to_target
        
    else:
        ordered_path=[]
        max_idx=len(path_to_target)-1
        for i in range(len(path_to_target)):
            idx=max_idx-i
            elem=path_to_target[idx]
            ordered_path.append(elem)
        
        ordered_path.append(target)
        path_to_target=ordered_path
        
    
    
    
    final=get_final_path(path_to_target,g.node_name_dict)
    
    
    # print('fsdfds',graph.path_dict)
    print("path to target>>",path_to_target)
    print('Final path is>>',final)
    
    plot_path(final)
    
    return my_dict




def plot_path(path):
    
    Infected_list=[235442763, 235441418, 235441532, 8866175149, 8866175150, 735025587, 735025605, 735025581, 735025575, 1737438402, 1737429144, 110063, 109699, 9814249421, 1122666438, 1122666475, 207558911, 7394550429, 735042706, 735391277, 735391283, 12196664, 1973883128, 1973882968, 12196781, 306462537, 407098828, 392512612, 6024047911, 1938018124, 1938018125, 392513284]
    inf_long=[]
    inf_lat=[]
    lat_arr=[]
    long_arr=[]
    data_arr=[]
    
    for node in path:
        for j in node_list_data:
            if node==j[0]:
                latitude=j[1]['y']
                longitude=j[1]['x']
                lat_arr.append(latitude)
                long_arr.append(longitude)
                
                
    for i in Infected_list:
        for node in node_list_data:
            if node[0]==i:
                latitude=node[1]['y']
                longitude=node[1]['x']
                inf_lat.append(latitude)
                inf_long.append(longitude)
                
                
            
                
                
    print('lat array',lat_arr)
    print('long array',long_arr)
                
                
    if len(lat_arr)==len(long_arr)==len(path):
        print('makes sense')
        
        
    for i in range(len(lat_arr)):
        element=(lat_arr[i],long_arr[i])
        
        data_arr.append(element)
    global df
        
    df=pd.DataFrame(data_arr,columns=['Lat','Long'])
    
    
    print('THE DATAFRAME IS>>',df )
    
    lat_center = np.mean(lat_arr)
    long_center = np.mean(long_arr)
    
    
        
    fig = go.Figure(go.Scattermapbox(
        name = "Path",
        mode = "lines",
        lon = long_arr,
        lat = lat_arr,
        marker = {'size': 10},
        line = dict(width = 4.5, color = 'black')))
    
    fig.update_layout(mapbox_accesstoken=api_token)
    
    
    # defining the layout using mapbox_style
    
    fig.update_layout(mapbox_accesstoken=api_token)
    fig.update_layout(mapbox_style="open-street-map")
    fig.update_layout(margin={"r":0,"t":0,"l":0,"b":0},
                      mapbox = {
                          'center': {'lat': lat_center, 
                          'lon': long_center},
                          'zoom': 13})
    
    
    

   
    # adding source marker
    fig.add_trace(go.Scattermapbox(
        name = "Source",
        mode = "markers",
        lon = [long_arr[0]],
        lat = [lat_arr[0]],
        marker = {'size': 12, 'color':"blue"}))
     
    # # adding destination marker
    fig.add_trace(go.Scattermapbox(
        name = "Destination",
        mode = "markers",
        lon = [long_arr[len(long_arr)-1]],
        lat = [lat_arr[len(long_arr)-1]],
        marker = {'size': 12, 'color':'green'}))
    
    
    inflat,inflong=request_coordinates()
    
    fig.add_trace(go.Scattermapbox(
        name = "Infected(added from server)",
        mode = "markers",
        lon =[inflong],
        lat =[inflat],
        marker = {'size': 12, 'color':'grey'}))
    
    
    
    for i in range(len(inf_lat)):
        fig.add_trace(go.Scattermapbox(
            name = "Infected",
            mode = "markers",
            lon =[inf_long[i]],
            lat =[inf_lat[i]],
            marker = {'size': 12, 'color':'red'}))
    
    
    fig.show(renderer='jpg')
    
    
    
    
        
                              


####Recursively cappend the shortest_path_nodes
def get_path_to_node(path_dict,start,target,path_list):
    
    previous_node=path_dict[target]
    path_list.append(previous_node)
    print('path list',path_list) 
    
    if previous_node==start:
        return path_list
    else:
        get_path_to_node(path_dict, start, previous_node,path_list)
        return path_list
    
    
    
def get_final_path(ordered_path,node_name_dict):
    
    final=[]
    for node in ordered_path:
        for key,value in node_name_dict.items():
            if node==value:
                final.append(key)
                
    return final
                
            
            
            
  




def request_coordinates():

    resp=req.get("http://www.tarekfinalproject.com/data.php") 
    
    print('response :',resp.text)
    
    
    response_string=resp.text 
    
    
    long_string=[]
    lat_string=[]
    max_idx=len(response_string)
    
    for idx, i in enumerate(response_string):
        if i=='L':
            if response_string[idx+1]=='A' and response_string[idx+2]=='T':
                
                first_idx=idx+3
                
                while first_idx<max_idx:
                    
                    if response_string[first_idx]=='L':
                        break
                    else:
                        elem=response_string[first_idx]
                        lat_string.append(elem)
                        first_idx+=1
                    
                
            elif response_string[idx+1]=='O' and response_string[idx+2]=='N':
                
              first_idx=idx+3
              
              while first_idx<max_idx:
                  
                  if response_string[first_idx]==' ':
                      break
                  else:
                      elem=response_string[first_idx]
                      long_string.append(elem)
                      first_idx+=1
                      
        
        
        
                      
    print("LAT STRING",lat_string)
    print("LONG STRING",long_string)
    latitude=split_dec(lat_string)
    longitude=split_dec(long_string)
        
    print(f'LATITUDE: {latitude} , LONGITUDE : {longitude}')
    return (latitude,longitude)
        
        
                      
                      
                  
 


def split_dec(string):
    
    negative_flag=1
    l1=[]
    l2=[]
    
    if string[0]=='-':
        negative_flag=-1
        string=string[1:]
    
    flag=0
    for i in range(len(string)):
        
        if string[i]=='.':
            flag=1
            
        if flag==1:
            l2.append(string[i])
            
            
        else:
            l1.append(string[i])
            
    l2=l2[1:]
    
    
    first=get_integer(l1)
    second=get_integer(l2)
    second=second/10**len(l2)
    print(first,second)
    final=(first+second)*negative_flag
   
    print(final)
    return final
    

        

                  
def get_integer(string):
    sums=0
    
    length=len(string)
    
    for i in range(length):
      
        element=int(string[i])*(10**(length-i-1))
            
        print('element is',element)
        
        sums=sums+element
        
    return sums
            
       
        
    

    
g=Graph(node_list, edge_list)


starting_node=node_list[10]
converted_starting_node=g.node_name_dict[starting_node]

target=node_list[1000]
target=g.node_name_dict[target]

Infected_list=[235442763, 235441418, 235441532, 8866175149, 8866175150, 735025587, 735025605, 735025581, 735025575, 1737438402, 1737429144, 110063, 109699, 9814249421, 1122666438, 1122666475, 207558911, 7394550429, 735042706, 735391277, 735391283, 12196664, 1973883128, 1973882968, 12196781, 306462537, 407098828, 392512612, 6024047911, 1938018124, 1938018125, 392513284]


for i in Infected_list:
    g.set_infected_node(i)
    
# g.set_edges(8866175150, 735025587, float('inf'))
# g.set_edges(9814249421, 1122666438, float('inf'))
# g.set_edges(12196664, 1973883128, float('inf'))




    

d=Djisktra(g,converted_starting_node)


origin_node=node_list[0]

destination_node=node_list[10]
route = nx.shortest_path(G, origin_node, destination_node, weight = 'length')












    
    