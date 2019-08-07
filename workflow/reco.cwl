class: CommandLineTool
cwlVersion: v1.0

requirements:
  - class: DockerRequirement
    dockerPull: cmsopendata/cmssw_4_2_8

baseCommand:
  - /bin/zsh

inputs:
  library: File
  build_file: File
  validation_script: File

arguments:
  - position: 0
    prefix: '-c'
    valueFrom: |
      source /opt/cms/cmsset_default.sh
      scramv1 project CMSSW CMSSW_4_2_8
      cd CMSSW_4_2_8/src
      eval `scramv1 runtime -sh`
      mkdir Reconstruction && cd Reconstruction
      mkdir Validation && cd Validation
      cmsDriver.py reco -s RAW2DIGI,L1Reco,RECO,USER:EventFilter/HcalRawToDigi/hcallaserhbhehffilter2012_cff.hcallLaser2012Filter --data --filein='root://eospublic.cern.ch//eos/opendata/cms/Run2010B/Jet/RAW/v1/000/146/807/04DC3275-DFCA-DF11-B54B-003048F024FA.root' --conditions FT_R_42_V10A::All --eventcontent AOD  --no_exec --python reco_cmsdriver.py
      sed -i 's/from Configuration.AlCa.GlobalTag import GlobalTag/process.GlobalTag.connect = cms.string("sqlite_file:\/cvmfs\/cms-opendata-conddb.cern.ch\/FT_R_42_V10A.db")/g' reco_cmsdriver.py
      sed -i 's/# Other statements/from Configuration.AlCa.GlobalTag import GlobalTag/g' reco_cmsdriver.py
      sed -i "s/process.GlobalTag = GlobalTag(process.GlobalTag, 'FT_R_42_V10A::All', '')/process.GlobalTag.globaltag = 'FT_R_42_V10A::All'/g" reco_cmsdriver.py
      ln -sf /cvmfs/cms-opendata-conddb.cern.ch/FT_R_42_V10A FT_R_42_V10A
      ln -sf /cvmfs/cms-opendata-conddb.cern.ch/FT_R_42_V10A.db FT_R_42_V10A.db
      ls -l
      ls -l /cvmfs/
      cmsRun reco_cmsdriver.py
      mkdir src
      scp ../../../../../../src/$(inputs.library.basename) ./src
      scp ../../../../../../$(inputs.build_file.basename) .
      scp ../../../../../../$(inputs.validation_script.basename) .
      scram b
      cmsRun $(inputs.validation_script.basename)

outputs:
  - id: result.root
    type: File
    outputBinding:
      glob: CMSSW_4_2_8/src/Reconstruction/Validation/reco_RAW2DIGI_L1Reco_RECO_USER.root
  - id: histo.root
    type: File
    outputBinding:
      glob: CMSSW_4_2_8/src/Reconstruction/Validation/histodemo.root
  - id: reco.log
    type: stdout

stdout: reco.log