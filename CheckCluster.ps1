#check cluster microsoft
import-module FailoverClusters 
Get-ClusterResource | select name,state
