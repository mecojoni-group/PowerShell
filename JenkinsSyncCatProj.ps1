$SourcePath = "F:\ZZ_Source"
$Categories = Get-ChildItem $SourcePath -Directory -Name

$FileName = "F:\config.xml"
$Pattern = "</hudson.model.AllView>"
$FileOriginal = Get-Content $FileName

[String[]] $FileModified = @()

foreach ($Line in $FileOriginal)
{   
    $FileModified += $Line

    if ($Line -match $Pattern) 
    {
        foreach ($Category in $Categories)
        {
            
            $SubFolders = Get-ChildItem $SourcePath\$Category -Directory -Name

            #Add Lines after the selected pattern 
            $FileModified += @"
    <hudson.plugins.view.dashboard.Dashboard plugin="dashboard-view@2.14"> 
     <owner class="hudson" reference="../../.."/> 
     <name>$Category</name>
     <filterExecutors>false</filterExecutors>
     <filterQueue>false</filterQueue>
     <properties class="hudson.model.View$PropertyList"/>
     <jobNames>
       <comparator class="hudson.util.CaseInsensitiveComparator"/>
"@
      foreach ($SubFolder in $SubFolders)
       { 
           $FileModified += "        <string>$SubFolder</string>"
       }

       $FileModified += @"
     </jobNames>
     <jobFilters/>
     <columns>
      <hudson.views.StatusColumn/>
      <hudson.views.WeatherColumn/>
      <hudson.views.JobColumn/>
      <hudson.views.LastSuccessColumn/>
      <hudson.views.LastFailureColumn/>
      <hudson.views.LastDurationColumn/>
      <hudson.views.BuildButtonColumn/>
      </columns>
     <recurse>true</recurse>
     <useCssStyle>false</useCssStyle>
     <includeStdJobList>true</includeStdJobList>
     <hideJenkinsPanels>false</hideJenkinsPanels>
     <leftPortletWidth>50%</leftPortletWidth>
     <rightPortletWidth>50%</rightPortletWidth>
     <leftPortlets/>
     <rightPortlets/>
     <topPortlets/>
     <bottomPortlets/>
    </hudson.plugins.view.dashboard.Dashboard>
"@
         }
    }
}
Set-Content $FileName $FileModified 