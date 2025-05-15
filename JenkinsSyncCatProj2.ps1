$SourcePath = "F:\ZZ_Source"
$Now = Get-Date -format "yyyy.MM.dd.hhmmss"
$BackupPath = "D:\Jenkins\Backup\config" + "_" + $Now + ".xml"
$Categories = Get-ChildItem $SourcePath -Directory -Name

$FileName = "F:\config.xml"

#Copy-Item $FileName -Destination $BackupPath

[String[]] $FileModified = @()
$Content = [IO.File]::ReadAllText($FileName)
$Hudson = $Content.IndexOf('<hudson.plugins.view.dashboard.Dashboard plugin')
$EndHudson = $Content.IndexOf(">",$Hudson)
$PluginVersion = $Content.Substring($Hudson,$EndHudson - $Hudson +1)
$View = $Content.IndexOf('  </views>')

if ($Hudson -gt 0 ){
    $FileModified += $Content.Substring(0,$Hudson)
}
else{
    $FileModified += $Content.Substring(0,$View)
}

$FileModified += @"
    $PluginVersion
      <owner class="hudson" reference="../../.."/>
      <name> Jenkins_Management</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
"@
$FileModified += @'
      <properties class="hudson.model.View$PropertyList"/>
      <jobNames>
        <comparator class="hudson.util.CaseInsensitiveComparator" reference="../../../hudson.plugins.view.dashboard.Dashboard/jobNames/comparator"/>
        <string>Sync_Cat_Proj</string>
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
'@

foreach ($Category in $Categories)
{
            
            $SubFolders = Get-ChildItem $SourcePath\$Category -Directory -Name

            #Add Lines after the selected pattern 
$FileModified += @"
    $PluginVersion 
      <owner class="hudson" reference="../../.."/>
      <name>$Category</name>
      <filterExecutors>false</filterExecutors>
      <filterQueue>false</filterQueue>
"@
$FileModified += @'
      <properties class="hudson.model.View$PropertyList"/>
'@
$FileModified += @"
      <jobNames>
        <comparator class="hudson.util.CaseInsensitiveComparator" reference="../../../hudson.plugins.view.dashboard.Dashboard/jobNames/comparator"/>
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

$FileModified += $Content.Substring($View, $Content.Length - $View)
Set-Content $FileName $FileModified