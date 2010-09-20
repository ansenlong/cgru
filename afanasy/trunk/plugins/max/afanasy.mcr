Macroscript Afanasy
ButtonText:"Afanasy..."
category:"CGRU"
toolTip:"Render by Afanasy..."
(
global ver = "Afanasy"

-- Set initial parameters:
-- Job name:
local jobname = maxFileName
local startFrame = rendStart.frame as integer
local endFrame = rendEnd.frame as integer
local byFrame = rendNThFrame
local taskFrameNumber = 1
local saveTempScene = false
local startPaused = false

-- Get scene cameras:
local CameraNames = #("")
for cam in cameras do
(
   if cam.isTarget then continue
   append CameraNames cam.name
)

-- Get batch render views:
local BatchViewNames = #("", "all")
for i = 1 to batchRenderMgr.numViews do
(
   local batchview = batchRenderMgr.getView i
   append BatchViewNames batchview.name
)

-- Delete old dialog:
if (AfanasyDialog != undefined) do
(
   try DestroyDialog AfanasyDialog
   catch ()
)   

rollout AfanasyDialog ver
(
-- Job name:
   edittext jobnameControl "Job Name" text:jobname
-- Frame range:
   spinner startFrameControl "Start Frame" range:[1,99999,startFrame] type:#integer scale:1 toolTip:"First frame to render."
   spinner endFrameControl "End Frame" range:[1,99999,endFrame] type:#integer scale:1 toolTip:"Last Frame to render."
   spinner byFrameControl "By Frame" range:[1,999,byFrame] type:#integer scale:1 toolTip:"Render every Nth frame."
   spinner taskFrameNumberControl "Frames Per Task" range:[1,999,taskFrameNumber] type:#integer scale:1 toolTip:"Number of frames in one task."
-- Cameras:
   dropdownlist cameraControl "Override Camera" items:CameraNames toolTip:"Override render camera."
-- Batch views:
   dropdownlist batchControl "Render Batch View" items:BatchViewNames toolTip:"Render batch view."
-- Priority:
   spinner priorityControl "Priority" range:[-1,99,-1] type:#integer scale:1 toolTip:"Job order."
-- Maximum hosts:
   spinner maxHostsControl "Max Hosts" range:[-1,9999,-1] type:#integer scale:1 toolTip:"Maximum number of hosts job can run on."
-- Capacity:
   spinner capacityControl "Capacity" range:[-1,999999,-1] type:#integer scale:1 toolTip:"Job tasks capacity."
-- Depend mask:
   edittext dependMaskControl "Depend Mask" toolTip:"Jobs to wait names pattern (same user)."
-- Global Depend mask:
   edittext globalMaskControl "Global Depend" toolTip:"Jobs to wait names pattern (all users)."
-- Hosts mask:
   edittext hostsMaskControl "Hosts Mask" toolTip:"Hosts names pattern job can run on."
-- Exclude hosts:
   edittext excludeHostsControl "Exclude Hosts" toolTip:"Hosts names pattern job can not run on."
-- Save temporarry scene:
   checkbox useTempControl "Save Temporary Scene" checked:saveTempScene toolTip:"Save scene to temporary file before render."
-- Render button:
   button renderButton "Render" toolTip:"Start Render Proces."
-- Start job paused:
   checkbox pauseControl "Start Job Paused" checked:startPaused toolTip:"Send job paused."

   on batchControl selected i do
   (
      local restore = true
      if i > 2 then
      (
         local numview = i - 2
         local batchview = batchRenderMgr.getView numview
         if batchview.overridePreset then
         (
            startFrameControl.value = batchview.startFrame
            endFrameControl.value = batchview.endFrame
            restore = false
         )
      )
      if restore then
      (
         startFrameControl.value = startFrame
         endFrameControl.value = endFrame
      )
   )
   
   on renderButton pressed do
   (
-- Save scene:
      checkForSave()

-- Create command:
      local cmd = "afjob.py "
      cmd += "\"" + maxFilePath + maxFileName + "\""
      cmd += " " + (startFrameControl.value as string)
      cmd += " " + (endFrameControl.value as string)
      cmd += " -fpt " + (taskFrameNumberControl.value as string)
      cmd += " -by " + (byFrameControl.value as string)
      if priorityControl.value > -1 then cmd += " -priority " + (priorityControl.value as string)
      if maxHostsControl.value > -1 then cmd += " -maxhosts " + (maxHostsControl.value as string)
      if capacityControl.value > -1 then cmd += " -capacity " + (capacityControl.value as string)
      if jobnameControl.text      != "" then cmd += " -name \""      + jobnameControl.text      + "\""
      if dependMaskControl.text   != "" then cmd += " -depmask \""   + dependMaskControl.text   + "\""
      if globalMaskControl.text   != "" then cmd += " -depglbl \""   + globalMaskControl.text   + "\""
      if hostsMaskControl.text    != "" then cmd += " -hostsmask \"" + hostsMaskControl.text    + "\""
      if excludeHostsControl.text != "" then cmd += " -hostsexcl \"" + excludeHostsControl.text + "\""
      if pauseControl.checked == true then cmd += " -pause"
      if useTempControl.checked == true then (
         cmd += " -tempscene"
         cmd += " -deletescene"
      )
      if cameraControl.selection > 1 then cmd += " -node \"" + cameraControl.selected + "\""
      if batchControl.selection > 1 then
      (
         cmd += " -take \"" + batchControl.selected + "\""
         if batchControl.selection > 2 then
         (
            local batchview = batchRenderMgr.getView(batchControl.selection-2)
            local image = batchview.outputFilename
            if image != "" then cmd += " -image \"" + image + "\""
         )
      )
      else
      (
         if rendOutputFilename != "" then cmd += " -image \"" + rendOutputFilename + "\""
      )

-- Prepare  command:
      cmd = systemTools.getEnvVariable("AF_ROOT") + "\\python\\" + cmd
      cmd = "python " + cmd
      format "-- %\n" cmd

-- Prepare command output file
      local outputfile = "afanasy_submint_max.txt"
      local tempdir = systemTools.getEnvVariable("TMP")
      if tempdir == undefined then tempdir = systemTools.getEnvVariable("TEMP")
      if tempdir == undefined then tempdir = "c:\\temp"
      local outputfile = tempdir + "\\" + outputfile

-- Launch command with redirected output:
      HiddenDOSCommand (cmd + " > " + outputfile + " 2>&1") ExitCode:&status

-- Output error if bad command exit status:
      if status != 0 then
      (
         format "-- %\n" "Error:"
         local outtext = openfile outputfile
         while not eof outtext do
         (
            local str = readLine outtext
            format "-- %\n" str
         )
         close outtext
      )
   )
)
CreateDialog  AfanasyDialog style:#(#style_titlebar, #style_border, #style_sysmenu,#style_minimizebox,#style_sunkenedge)
)