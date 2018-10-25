unit SimHints;

interface

  uses
    Languages;

  const
    mtidHintsDenied            : TRegMultiString = nil;  //  'This facility belongs to %s. There are no hints for you.';
    mtidVisitWebSite           : TRegMultiString = nil;  //  'No hints for this facility.';
    mtidNeedsMoney             : TRegMultiString = nil;  //  'Hint: Stop all facilities that are losing money.';
    mtidNeedsConnection        : TRegMultiString = nil;  //  'Hint: Go to "Settings" and hire some suppliers.';
    mtidNeedsSomeConnection    : TRegMultiString = nil;  //  'Warning: This facility needs supplier for %s.';
    mtidSuppliesDropped        : TRegMultiString = nil;  //  'Warning: Supplier of %s have dropped. Hire another suppliers.';
    mtidSalesDropped           : TRegMultiString = nil;  //  'Warning: Sales of %s have dropped. Get hired by another facilities.';
    mtidSuppliesBeingImported  : TRegMultiString = nil;  //  'Hint: You are importing %s because your suppliers are selling to another people.';
    mtidSuppliesRedirected     : TRegMultiString = nil;  //  'Warning: Your suppliers of %s are selling their entire production to different people.';
    mtidNeedsWorkForce         : TRegMultiString = nil;  //  'Warning: this facility needs more %s work force.';
    mtidNeedsCompSupport       : TRegMultiString = nil;  //  'Warning: Not enough company support. You must build more headquarters or attract more people to those already built.';
    mtidBlockNeedsWorkForce    : TRegMultiString = nil;  //  'Warning: This facility needs %s work force.';
    mtidUpgrading              : TRegMultiString = nil;
    mtidUpgradeLevel           : TRegMultiString = nil;

    // Construction
    mtidConstFromTradeCenter   : TRegMultiString = nil;  //  'Hint: The Trade Center was hired to construct this. You could hire someone cheaper.';

    // Residentials
    mtidResVeryUnderPopulated  : TRegMultiString = nil;  //  'Warning: You need to attract more people to this building.';
    mtidResUnderPopulated      : TRegMultiString = nil;  //  'Hint: You need to attract more people to this building.';
    mtidResMildUnderPopulated  : TRegMultiString = nil;  //  'Hint: You still can attract more people to this building.';
    mtidTownUnderPopulated     : TRegMultiString = nil;  //  'Hint: There are too few people in %s. You will have to compete fiercely. Try making the rent lower.';
    mtidResWorkingFine         : TRegMultiString = nil;  //  'Congratulations: This building is working OK. Perhaps you can rise the rent a little bit.';
    mtidResWorking             : TRegMultiString = nil;
    mtidResClosedHeader        : TRegMultiString = nil;
    mtidResClosedByLine        : TRegMultiString = nil;
    mtidResRepaired            : TRegMultiString = nil;
    mtidResSecReport           : TRegMultiString = nil;
    mtidPopBlkClone            : TRegMultiString = nil;


    // Public facilities
    mtidVisitTownHall          : TRegMultiString = nil;  //  'Hint: Visit Town Hall''s Web Site to find valuable information.';
    mtidVisitTradeCenter       : TRegMultiString = nil;  //  'Hint: Visit Trade Center''s Web Site to see who is selling or buying what.';
    mtidPeopleIn               : TRegMultiString = nil;  //  '%d citizens of %s moved in last day. ';
    mtidPeopleInRes            : TRegMultiString = nil;  //  '%d%% due to good residential offers, ';
    mtidPeopleInWork           : TRegMultiString = nil;  //  '%d%% to find a job, ';
    mtidPeopleInQOL            : TRegMultiString = nil;  //  '%d%% due to good quality of public services. ';
    mtidPeopleOut              : TRegMultiString = nil;  //  '%d citizens of %s moved out last day. ';
    mtidPeopleOutWork          : TRegMultiString = nil;  //  '%d%% due to salaries and work conditions, ';
    mtidPeopleOutRes           : TRegMultiString = nil;  //  '%d%% due to residential conditions, ';
    mtidPeopleOutQOL           : TRegMultiString = nil;  //  '%d%% due to low coverage of public services, ';
    mtidPeopleOutUnemp         : TRegMultiString = nil;  //  '%d%% due to unemployment, ';
    mtidPeopleOutServ          : TRegMultiString = nil;  //  '%d%% due to lack of products and services. ';
    mtidPeopleOutDisasters     : TRegMultiString = nil;  //  '%d%% due to disasters. ';
    mtidNoMovements            : TRegMultiString = nil;  //  'No %s movements.';
    mtidTHMainText             : TRegMultiString = nil;
    mtidTHPopReport            : TRegMultiString = nil;

    // Headquarters
    mtidGeneralHQResearch      : TRegMultiString = nil;  //  'Hint: Be sure there are enought workers to carry out the research.';
    mtidHQResearch             : TRegMultiString = nil;  //  'Hint: Well, %s, this is a good time to go to Voyager''s Mail and write a love letter...';
    mtidHQIdle                 : TRegMultiString = nil;  //  'Hint: Go to "Settings" to carry out new researchs.';
    mtidResearchMain           : TRegMultiString = nil;
    mtidResearchSec            : TRegMultiString = nil;
    mtidCompSupported          : TRegMultiString = nil;
    mtidImplementationCost     : TRegMultiString = nil;
    mtidResCenterCloneMenu     : TRegMultiString = nil;

    // Services
    mtidServiceHiClassSpecialized  : TRegMultiString = nil;  //  'Hint: Are you trying to sell mainly to high class people? Then quality is the key.';
    mtidServiceLoClassSpecialized  : TRegMultiString = nil;  //  'Hint: Are you trying to sell mainly to low class people? Then price is the key.';
    mtidServiceHighCompetition     : TRegMultiString = nil;  //  'Warning: You have a problem with competition. Get some advertisement.';
    mtidServiceWrongConception     : TRegMultiString = nil;  //  'Warning: It seams that you are targeting costumers in a wrong way.';
    mtidServiceWrongPlace          : TRegMultiString = nil;  //  'Hint: Try to attract more customers by offering better quality and prices.';
    mtidServiceWorkingFineButLow   : TRegMultiString = nil;  //  'Congratulations: This facility is running OK. Anyway you could attend more people.';
    mtidServiceWorkingFine         : TRegMultiString = nil;  //  'Congratulations: This facility is running OK. Just keep this way.';
    mtidServiceLowSupplies         : TRegMultiString = nil;  //  'Warning: %s service need more supplies.';
    mtidServiceOpening             : TRegMultiString = nil;  //  'The facility started just few hours ago, there are no hints for now.';
    mtidServiceSecondary           : TRegMultiString = nil;
    mtidServiceEfficiency          : TRegMultiString = nil; // Efficiency
    mtidServiceDesirability        : TRegMultiString = nil; // Desirability
    mtidServiceCloneMenu           : TRegMultiString = nil;

    // Evaluated blocks
    mtidEvalBlockNotProducing           : TRegMultiString = nil;  //  'Hint: Not producing %s. You have no customers.';
    mtidEvalBlockNeedsBasicInput        : TRegMultiString = nil;  //  'Warning: This facility requires %s to produce. Hire some suppliers or try to overpay those you already have.';
    mtidEvalBlockNeedsMoreSupplies      : TRegMultiString = nil;  //  'Hint: This facility needs more %s to produce %s.';
    mtidEvalBlockNeedsConnections       : TRegMultiString = nil;  //  'Hint: Go to "Settings" and hire more suppliers for %s.';
    mtidEvalBlockAvoidTradeCenter       : TRegMultiString = nil;  //  'Hint: You are buying from a Trade Center. Find some local suppliers.';
    mtidEvalBlockBadWeatherCond         : TRegMultiString = nil;  //  'There is nothing we can do about the weather but wait.';
    mtidEvalBlockNeedTechnology         : TRegMultiString = nil;  //  'Warning: Cannot operate until you research again %s.';
    mtidEvalBlockNeedsMoreCompSupplies  : TRegMultiString = nil;  //  'Warning: This facility is lacking services. Check the Services Tab on the INSPECT panel.';
    mtidSupplies                        : TRegMultiString = nil;
    mtidEvalBlockCloneMenu              : TRegMultiString = nil;  //  'Price|%d|Suppliers|%d|Clients|%d|'
    mtidEvalBlockProducing              : TRegMultiString = nil;  // Producing :

    // Public
    mtidTownNeedsMoreResidentials  : TRegMultiString = nil;  //  'Hint: This town requires more residentials for %s people.';
    mtidTownNeedsMoreCommerce      : TRegMultiString = nil;  //  'Hint: New stores and other services would encourage economic activity.';
    mtidTownHighUnemployment       : TRegMultiString = nil;  //  'Warning: There is a %d%% of unemployment in %s people.';
    mtidTownLowPublicService       : TRegMultiString = nil;  //  'Warning: There is a problem with %s.';
    mtidPublicFacNeedsWorkers      : TRegMultiString = nil;  //  'Hint: You should attract more workers to this facility in case you want to rise its operation ratio.';
    mtidPublicFacNeedsSupport      : TRegMultiString = nil;  //  'Hint: This facility needs more support from its headquarters.';
    mtidPubFacCov                  : TRegMultiString = nil;  //  '%s coverage accross the city reported at %d%%.';
    mtidEmptyCity                  : TRegMultiString = nil;  //  'This city is not populated!';

    // Context status texts
    mtidDesertedTown         : TRegMultiString = nil;  //  '%s is not populated. Invest here and the %s order will give you an aditional amount of money.';
    mtidPublicServiceNeeded  : TRegMultiString = nil;  //  'Citizens of %s demand more %s.';
    mtidServiceNeeded        : TRegMultiString = nil;  //  'Citizens of %s demand more %s.';
    mtidVisitNewspaper       : TRegMultiString = nil;  //  'For more information about %s visit %s, the local newspaper.';

    // Facility Descriptions
    mtidDescResidential   : TRegMultiString = nil;  //  '%s residential. %d inhabitants. %d%% resistent to crime, %d%% resistent to pollution. Design quality: %d%%.';
    mtidDescOffice        : TRegMultiString = nil;  //  '%d offices to rent. Design quality: %d%%.';
    mtidDescFactoryHead   : TRegMultiString = nil;  //  'Produces up to ';
    mtidDescFactoryHeadN  : TRegMultiString = nil;  //  '%s of %s';
    mtidDescFactoryReq    : TRegMultiString = nil;  //  'Requires ';
    mtidDescFactoryReqN   : TRegMultiString = nil;  //  '%s';
    mtidWorkCenterHead    : TRegMultiString = nil;  //  'Employs: ';
    mtidTechRequired      : TRegMultiString = nil;  //  'Requires research %s at %s.';
    mtidWHHead            : TRegMultiString = nil;  //  'Stores up to ';
    mtidWCenterClone      : TRegMultiString = nil;

    mtidDescStoreInput    : TRegMultiString = nil;
    mtidDescStoreResell1  : TRegMultiString = nil;
    mtidDescStoreTailStr  : TRegMultiString = nil;
    mtidDescStoreCombine1 : TRegMultiString = nil;
    mtidDescStoreCombine2 : TRegMultiString = nil;

    // Alerts
    mtidFacilityWillBeDemolished  : TRegMultiString = nil;  //  'ATENTION! THE MAYOR OF %s REQUESTED THE DEMOLITION OF THIS BUILDING DUE TO CITY PLANNING. DEMOLITION WILL TAKE PLACE IN %d MONTHS. THE GOVERNMENT WILL PAY YOU %s AS A COMPENSATION.';

    // Curriculum
    mtidOwnershipReport    : TRegMultiString = nil;  //  'Controls %d companies, %d facilities.';
    mtidResearchReport     : TRegMultiString = nil;  //  'Research report
    mtidWonElections       : TRegMultiString = nil;  //  'Was elected Mayor of %s in the campaign of %d.';
    mtidWasMayor           : TRegMultiString = nil;  //  'Was Mayor of %s from %d to %d with a %d%% of popular rating.';
    mtidWasFiredFromMayor  : TRegMultiString = nil;  //  'Was fired from Mayor of %s in %d.';
    mtidWasPresident       : TRegMultiString = nil;  //  'Was President of %s from %d to %d with a %d%% of popular rating.';
    mtidWonWorldElections  : TRegMultiString = nil;  //  'Was elected President of %s in the campaign of %d.';
    mtidWasMinister        : TRegMultiString = nil;  //  'Was Minister of %s from %d to %d with a %d%% of IFEL rating.';
    mtidAppointedMinister  : TRegMultiString = nil;  //  'Was appointed Minister of %s in the campaign of %d by %s.';
    mtidBankrupt           : TRegMultiString = nil;  //  'Was declared in bankrupty in %d';
    mtidTranscended        : TRegMultiString = nil;  //  'Transcended in %d';

    // Levels
    mtidLevelAchieved                        : TRegMultiString = nil;  //  'Achieved level %s in %d';
    mtidNotEnoughMoney                       : TRegMultiString = nil;  //  'Could not upgrade level last year. You failed to pay $%.0n';
    mtidNotEnoughProfit                      : TRegMultiString = nil;  //  'Could not upgrade level last year. You require an average profit ratio of $%.0n/h (last year you had $%.0n/h)';
    mtidMustHaveBeenMayor                    : TRegMultiString = nil;  //  'You need to be elected Mayor at least once.';
    mtidMustHaveBeenPresident                : TRegMultiString = nil;  //  'You need to be elected President at least once.';
    mtidPrestigeRequired                     : TRegMultiString = nil;  //  'Could not upgrade level last year. You require %d prestige points';
    mtidNotEnoughPrestigeLostLevel           : TRegMultiString = nil;  //  'You failed to pay $%.0n';
    mtidNotEnoughProfitLostLevel             : TRegMultiString = nil;  //  'You require an average profit ratio of $%.0n/h (last year you had $%.0n/h)';
    mtidLevelLost                            : TRegMultiString = nil;
    mtidCouldNotUpgrade                      : TRegMultiString = nil;  //  'Could not

    // Misc
    mtidJoinedWorld  : TRegMultiString = nil;  //  'Joined %s in %d';
    mtidAND          : TRegMultiString = nil;  //

    // Events
    mtidSetTaxes                  : TRegMultiString = nil;
    mtidSubsidy                   : TRegMultiString = nil;
    mtidLaunchedCampaign          : TRegMultiString = nil;
    mtidCancelledCampaign         : TRegMultiString = nil;
    mtidMayorElected              : TRegMultiString = nil;
    mtidMayorReElected            : TRegMultiString = nil;
    mtidCityHasNoMayor            : TRegMultiString = nil;
    mtidMayorFired                : TRegMultiString = nil;
    mtidSubsidiesRemoved          : TRegMultiString = nil;
    mtidTycoonBankrupt            : TRegMultiString = nil;
    mtidFacBuilt                  : TRegMultiString = nil;
    mtidAccountReset              : TRegMultiString = nil;
    mtidMsgJoinedWorld            : TRegMultiString = nil;
    mtidSatelliteUpdated          : TRegMultiString = nil;
    mtidMinisterElected           : TRegMultiString = nil;
    mtidPresidentElected          : TRegMultiString = nil;
    mtidPresidentReElected        : TRegMultiString = nil;
    mtidNoPresident               : TRegMultiString = nil;
    mtidPresidenCampaignLaunched  : TRegMultiString = nil;
    mtidPresidenCampaignCancelled : TRegMultiString = nil;

    // Arrange later

    mtidCiviHQPrest          : TRegMultiString = nil;
    mtidPubFacMain           : TRegMultiString = nil;
    mtidCapitolMain          : TRegMultiString = nil;
    mtidCapitolWithPresSec   : TRegMultiString = nil;
    mtidCapitolWithNoPresSec : TRegMultiString = nil;
    mtidCapitolHint          : TRegMultiString = nil;
    mtidTVMainOne            : TRegMultiString = nil;
    mtidTVMainTwo            : TRegMultiString = nil;
    mtidTVSec                : TRegMultiString = nil;
    mtidHiringWorkForce      : TRegMultiString = nil;
    mtidHiringWorkForceSec   : TRegMultiString = nil;
    mtidTVWarning            : TRegMultiString = nil;
    mtidAntenaAudience       : TRegMultiString = nil;
    mtidAntenaRating         : TRegMultiString = nil;
    mtidAntenaHint           : TRegMultiString = nil;
    mtidConstruction         : TRegMultiString = nil;
    mtidStoppedDueWeather    : TRegMultiString = nil;
    mtidOfficeReport         : TRegMultiString = nil;
    mtidOfficeTitle          : TRegMultiString = nil;
    mtidOfficeOccup          : TRegMultiString = nil;
    mtidWarehouseRepHead     : TRegMultiString = nil;
    mtidWarehouseRepN        : TRegMultiString = nil;
    mtidMinisterName         : TRegMultiString = nil;
    mtidMinistryName         : TRegMultiString = nil;
    mtidCommerceMain         : TRegMultiString = nil;
    mtidOutputEvalFull       : TRegMultiString = nil;
    mtidOutputEval           : TRegMultiString = nil;
    mtidOutputSec            : TRegMultiString = nil;
    mtidInvPrice             : TRegMultiString = nil;
    mtidInvLicense           : TRegMultiString = nil;
    mtidInvImpCostYear       : TRegMultiString = nil;
    mtidInvImpCostHour       : TRegMultiString = nil;
    mtidInvUsage             : TRegMultiString = nil;
    mtidInvNobPoints         : TRegMultiString = nil;
    mtidInvPrestige          : TRegMultiString = nil;
    mtidInvLevel             : TRegMultiString = nil;
    mtidInvPayReduct         : TRegMultiString = nil;
    mtidInvJobQ              : TRegMultiString = nil;
    mtidInvBeauty            : TRegMultiString = nil;
    mtidInvMaintenance       : TRegMultiString = nil;
    mtidInvPrivacy           : TRegMultiString = nil;
    mtidInvCrimeRes          : TRegMultiString = nil;
    mtidInvPollRes           : TRegMultiString = nil;
    mtidInvEff               : TRegMultiString = nil;
    mtidInvDesirability      : TRegMultiString = nil;
    mtidInvQ                 : TRegMultiString = nil;
    mtidOfficeClone          : TRegMultiString = nil;

    // Transcendence

    mtidPlayerWillTranscend : TRegMultiString = nil;
    mtidBewareOfTranscend   : TRegMultiString = nil;

    // Lumber Industry

    mtidGrowingTrees        : TRegMultiString = nil; // 'Growing trees at %d%%'

    // Movie Studios

    mtidLicensingFilm       : TRegMultiString = nil; // 'Licensing: "%s"  Quality Index: %d%%.'
    mtidFilmProject         : TRegMultiString = nil; // 'Roling: "%s" Day %d of %d, %d%% done.'

    mtidNowPlaying          : TRegMultiString = nil; // Now playing

    // Inventions

    mtidInvCatGeneral   : TRegMultiString = nil; // General
    mtidInvCatCommerce  : TRegMultiString = nil; // Commerce
    mtidInvCatIndustry  : TRegMultiString = nil; // Industry
    mtidInvCatRlEstate  : TRegMultiString = nil; // Real Estate

  function GetHintText( HintId : string; parms : array of const ) : string;

  procedure InitMLS;


implementation

  uses
    SysUtils;

  function GetHintText( HintId : string; parms : array of const ) : string;
    begin
      try
        result := Format( HintId, parms );
      except
        result := '';
      end;
    end;

  procedure InitMLS;
    begin
      mtidHintsDenied           := TRegMultiString.Create( 'mtidHintsDenied', 'This facility belongs to %s. There are no hints for you.' );
      mtidVisitWebSite          := TRegMultiString.Create( 'mtidVisitWebSite', 'No hints for this facility.' );
      mtidNeedsMoney            := TRegMultiString.Create( 'mtidNeedsMoney', 'Hint: Stop all facilities that are losing money.' );
      mtidNeedsConnection       := TRegMultiString.Create( 'mtidNeedsConnection', 'Hint: Go to "Settings" and hire some suppliers.' );
      mtidNeedsSomeConnection   := TRegMultiString.Create( 'mtidNeedsSomeConnection', 'Warning: This facility needs supplier for %s.' );
      mtidSuppliesDropped       := TRegMultiString.Create( 'mtidSuppliesDropped', 'Warning: Supplier of %s have dropped. Hire another suppliers.' );
      mtidSalesDropped          := TRegMultiString.Create( 'mtidSalesDropped', 'Warning: Sales of %s have dropped. Get hired by another facilities.' );
      mtidSuppliesBeingImported := TRegMultiString.Create( 'mtidSuppliesBeingImported', 'Hint: You are importing %s because your suppliers are selling to another people.' );
      mtidSuppliesRedirected    := TRegMultiString.Create( 'mtidSuppliesRedirected', 'Warning: Your suppliers of %s are selling their entire production to different people.' );
      mtidNeedsWorkForce        := TRegMultiString.Create( 'mtidNeedsWorkForce', 'Warning: this facility needs more %s work force.' );
      mtidNeedsCompSupport      := TRegMultiString.Create( 'mtidNeedsCompSupport', 'Warning: Not enough company support. You must build more headquarters or attract more people to those already built.' );
      mtidBlockNeedsWorkForce   := TRegMultiString.Create( 'mtidBlockNeedsWorkForce', 'Warning: This facility needs %s work force.' );
      mtidUpgrading             := TRegMultiString.Create( 'mtidUpgrading', 'Upgrading: %d%%' );
      mtidUpgradeLevel          := TRegMultiString.Create( 'mtidUpgradeLevel', 'Upgrade Level: %d' );

      // Construction
      mtidConstFromTradeCenter  := TRegMultiString.Create( 'mtidConstFromTradeCenter', 'Hint: The Trade Center was hired to construct this. You could hire someone cheaper.' );

      // Residentials
      mtidResVeryUnderPopulated := TRegMultiString.Create( 'mtidResVeryUnderPopulated', 'Warning: You need to attract more people to this building.' );
      mtidResUnderPopulated     := TRegMultiString.Create( 'mtidResUnderPopulated', 'Hint: You need to attract more people to this building.' );
      mtidResMildUnderPopulated := TRegMultiString.Create( 'mtidResMildUnderPopulated', 'Hint: You still can attract more people to this building.' );
      mtidTownUnderPopulated    := TRegMultiString.Create( 'mtidTownUnderPopulated', 'Hint: There are too few people in %s. You will have to compete fiercely. Try making the rent lower.' );
      mtidResWorkingFine        := TRegMultiString.Create( 'mtidResWorkingFine', 'Congratulations: This building is working OK. Perhaps you can rise the rent a little bit.' );
      mtidResWorking            := TRegMultiString.Create( 'mtidResWorking', '%d%% %s occupancy' );
      mtidResClosedHeader       := TRegMultiString.Create( 'mtidResClosedHeader', '%s real estate' );
      mtidResClosedByLine       := TRegMultiString.Create( 'mtidResClosedByLine', '[closed]' );
      mtidResRepaired           := TRegMultiString.Create( 'mtidResRepaired', '%d%% repaired' );
      mtidResSecReport          := TRegMultiString.Create( 'mtidResSecReport', '%d inhabitants. %d quality index. QOL: %d%% Neighborhood Quality: %d%% Beauty: %d%% Crime: %d%% Pollution: %d%%.' );
      mtidPopBlkClone           := TRegMultiString.Create( 'mtidPopBlkClone', 'Rent|%d|Maintenance|%d|' );

      // Public facilities
      mtidVisitTownHall         := TRegMultiString.Create( 'mtidVisitTownHall', 'Hint: Visit Town Hall''s Web Site to find valuable information.' );
      mtidVisitTradeCenter      := TRegMultiString.Create( 'mtidVisitTradeCenter', 'Hint: Visit Trade Center''s Web Site to see who is selling or buying what.' );
      mtidPeopleIn              := TRegMultiString.Create( 'mtidPeopleIn', '%d citizens of %s moved in last day.' );
      mtidPeopleInRes           := TRegMultiString.Create( 'mtidPeopleInRes', '%d%% due to good residential offers, ' );
      mtidPeopleInWork          := TRegMultiString.Create( 'mtidPeopleInWork', '%d%% to find a job, ' );
      mtidPeopleInQOL           := TRegMultiString.Create( 'mtidPeopleInQOL', '%d%% due to good quality of public services.' );
      mtidPeopleOut             := TRegMultiString.Create( 'mtidPeopleOut', '%d citizens of %s moved out last day.' );
      mtidPeopleOutWork         := TRegMultiString.Create( 'mtidPeopleOutWork', '%d%% due to salaries and work conditions, ' );
      mtidPeopleOutRes          := TRegMultiString.Create( 'mtidPeopleOutRes', '%d%% due to residential conditions, ' );
      mtidPeopleOutQOL          := TRegMultiString.Create( 'mtidPeopleOutQOL', '%d%% due to low coverage of public services, ' );
      mtidPeopleOutUnemp        := TRegMultiString.Create( 'mtidPeopleOutUnemp', '%d%% due to unemployment, ' );
      mtidPeopleOutServ         := TRegMultiString.Create( 'mtidPeopleOutServ', '%d%% due to lack of products and services.' );
      mtidPeopleOutDisasters    := TRegMultiString.Create( 'mtidPeopleOutDisasters', '%d%% due to disasters.' );
      mtidNoMovements           := TRegMultiString.Create( 'mtidNoMovements', 'No %s movements.' );
      mtidTHMainText            := TRegMultiString.Create( 'mtidTHMainText', '%s inhabitants' );
      mtidTHPopReport           := TRegMultiString.Create( 'mtidTHPopReport', '%s %s (%d%% unemp)' );

      // Headquarters
      mtidGeneralHQResearch     := TRegMultiString.Create( 'mtidGeneralHQResearch', 'Hint: Be sure there are enought workers to carry out the research.' );
      mtidHQResearch            := TRegMultiString.Create( 'mtidHQResearch', 'Hint: Well, %s, this is a good time to go to Voyager''s Mail and write a love letter...' );
      mtidHQIdle                := TRegMultiString.Create( 'mtidHQIdle', 'Hint: Go to "Settings" to carry out new researchs.' );
      mtidResearchMain          := TRegMultiString.Create( 'mtidResearchMain', '%d%% research completed' );
      mtidResearchSec           := TRegMultiString.Create( 'mtidResearchSec', 'Researching %s. Cost: %s.' );
      mtidCompSupported         := TRegMultiString.Create( 'mtidCompSupported', 'Company supported at %d%%.' );
      mtidImplementationCost    := TRegMultiString.Create( 'mtidImplementationCost', 'Research Implementation: %s.' );
      mtidResCenterCloneMenu    := TRegMultiString.Create( 'mtidResCenterCloneMenu', 'Suppliers|%d|' );

      // Services
      mtidServiceHiClassSpecialized := TRegMultiString.Create( 'mtidServiceHiClassSpecialized', 'Hint: Are you trying to sell mainly to high class people? Then quality is the key.' );
      mtidServiceLoClassSpecialized := TRegMultiString.Create( 'mtidServiceLoClassSpecialized', 'Hint: Are you trying to sell mainly to low class people? Then price is the key.' );
      mtidServiceHighCompetition    := TRegMultiString.Create( 'mtidServiceHighCompetition', 'Warning: You have a problem with competition. Get some advertisement.' );
      mtidServiceWrongConception    := TRegMultiString.Create( 'mtidServiceWrongConception', 'Warning: It seams that you are targeting costumers in a wrong way.' );
      mtidServiceWrongPlace         := TRegMultiString.Create( 'mtidServiceWrongPlace', 'Hint: Try to attract more customers by offering better quality and prices.' );
      mtidServiceWorkingFineButLow  := TRegMultiString.Create( 'mtidServiceWorkingFineButLow', 'Congratulations: This facility is running OK. Anyway you could attend more people.' );
      mtidServiceWorkingFine        := TRegMultiString.Create( 'mtidServiceWorkingFine', 'Congratulations: This facility is running OK. Just keep this way.' );
      mtidServiceLowSupplies        := TRegMultiString.Create( 'mtidServiceLowSupplies', 'Warning: %s service need more supplies.' );
      mtidServiceOpening            := TRegMultiString.Create( 'mtidServiceOpening', 'The facility started just few hours ago, there are no hints for now.' );
      mtidServiceSecondary          := TRegMultiString.Create( 'mtidServiceSecondary', 'Potential customers (per day): %d hi, %d mid, %d low. Actual customers: %d hi, %d mid, %d low.' );
      mtidServiceEfficiency         := TRegMultiString.Create( 'mtidServiceEfficiency', 'Efficiency: %d%%' );
      mtidServiceDesirability       := TRegMultiString.Create( 'mtidServiceDesirability', 'Desirability: %d' );
      mtidServiceCloneMenu          := TRegMultiString.Create( 'mtidServiceCloneMenu', 'Price|%d|Suppliers|%d|Ads|%d|' );

      // Evaluated blocks
      mtidEvalBlockNotProducing          := TRegMultiString.Create( 'mtidEvalBlockNotProducing', 'Hint: Not producing %s. You have no customers.' );
      mtidEvalBlockNeedsBasicInput       := TRegMultiString.Create( 'mtidEvalBlockNeedsBasicInput', 'Warning: This facility requires %s to produce. Hire some suppliers or try to overpay those you already have.' );
      mtidEvalBlockNeedsMoreSupplies     := TRegMultiString.Create( 'mtidEvalBlockNeedsMoreSupplies', 'Hint: This facility needs more %s to produce %s.' );
      mtidEvalBlockNeedsConnections      := TRegMultiString.Create( 'mtidEvalBlockNeedsConnections', 'Hint: Go to "Settings" and hire more suppliers for %s.' );
      mtidEvalBlockAvoidTradeCenter      := TRegMultiString.Create( 'mtidEvalBlockAvoidTradeCenter', 'Hint: You are buying from a Trade Center. Find some local suppliers.' );
      mtidEvalBlockBadWeatherCond        := TRegMultiString.Create( 'mtidEvalBlockBadWeatherCond', 'There is nothing we can do about the weather but wait.' );
      mtidEvalBlockNeedTechnology        := TRegMultiString.Create( 'mtidEvalBlockNeedTechnology', 'Warning: Cannot operate until you research again %s.' );
      mtidEvalBlockNeedsMoreCompSupplies := TRegMultiString.Create( 'mtidEvalBlockNeedsMoreCompSupplies', 'Warning: This facility is lacking services. Check the Services Tab on the INSPECT panel.' );
      mtidSupplies                       := TRegMultiString.Create( 'mtidSupplies', 'supplies' );
      mtidEvalBlockCloneMenu             := TRegMultiString.Create('mtidEvalBlockCloneMenu', 'Price|%d|Suppliers|%d|Clients|%d|');
      mtidEvalBlockProducing             := TRegMultiString.Create('mtidEvalBlockProducing', 'Producing: ');

      // Public
      mtidTownNeedsMoreResidentials := TRegMultiString.Create( 'mtidTownNeedsMoreResidentials', 'Hint: This town requires more residentials for %s people.' );
      mtidTownNeedsMoreCommerce     := TRegMultiString.Create( 'mtidTownNeedsMoreCommerce', 'Hint: New stores and other services would encourage economic activity.' );
      mtidTownHighUnemployment      := TRegMultiString.Create( 'mtidTownHighUnemployment', 'Warning: There is a %d%% of unemployment in %s people.' );
      mtidTownLowPublicService      := TRegMultiString.Create( 'mtidTownLowPublicService', 'Warning: There is a problem with %s.' );
      mtidPublicFacNeedsWorkers     := TRegMultiString.Create( 'mtidPublicFacNeedsWorkers', 'Hint: You should attract more workers to this facility in case you want to rise its operation ratio.' );
      mtidPublicFacNeedsSupport     := TRegMultiString.Create( 'mtidPublicFacNeedsSupport', 'Hint: This facility needs more support from its headquarters.' );
      mtidPubFacCov                 := TRegMultiString.Create( 'mtidPubFacCov', '%s coverage accross the city reported at %d%%.' );
      mtidEmptyCity                 := TRegMultiString.Create( 'mtidEmptyCity', 'This city is not populated!' );

      // Context status texts
      mtidDesertedTown        := TRegMultiString.Create( 'mtidDesertedTown', '%s is not populated. Invest here and the %s order will give you an aditional amount of money.' );
      mtidPublicServiceNeeded := TRegMultiString.Create( 'mtidPublicServiceNeeded', 'Citizens of %s demand more %s.' );
      mtidServiceNeeded       := TRegMultiString.Create( 'mtidServiceNeeded', 'Citizens of %s demand more %s.' );
      mtidVisitNewspaper      := TRegMultiString.Create( 'mtidVisitNewspaper', 'For more information about %s visit %s, the local newspaper.' );

      // Facility Descriptions
      mtidDescResidential  := TRegMultiString.Create( 'mtidDescResidential', '%s residential. %d inhabitants. %d%% resistent to crime, %d%% resistent to pollution. Design quality: %d%%.' );
      mtidDescOffice       := TRegMultiString.Create( 'mtidDescOffice', '%d offices to rent. Design quality: %d%%.' );
      mtidDescFactoryHead  := TRegMultiString.Create( 'mtidDescFactoryHead', 'Produces up to' );
      mtidDescFactoryHeadN := TRegMultiString.Create( 'mtidDescFactoryHeadN', '%s of %s' );
      mtidDescFactoryReq   := TRegMultiString.Create( 'mtidDescFactoryReq', 'Requires' );
      mtidDescFactoryReqN  := TRegMultiString.Create( 'mtidDescFactoryReqN', '%s' );
      mtidWorkCenterHead   := TRegMultiString.Create( 'mtidWorkCenterHead', 'Employs:' );
      mtidTechRequired     := TRegMultiString.Create( 'mtidTechRequired', 'Requires research %s at %s.' );
      mtidWHHead           := TRegMultiString.Create( 'mtidWHHead', 'Stores up to ' );
      mtidWCenterClone     := TRegMultiString.Create( 'mtidWCenterClone', 'Salaries|%d|' );

      mtidDescStoreInput    := TRegMultiString.Create( 'mtidDescStoreInput', '%d %s of %s' );
      mtidDescStoreResell1  := TRegMultiString.Create( 'mtidDescStoreResell1', 'Sells up to' );
      mtidDescStoreTailStr  := TRegMultiString.Create( 'mtidDescStoreTailStr', 'per level.' );
      mtidDescStoreCombine1 := TRegMultiString.Create( 'mtidDescStoreCombine1', 'Buys up to' );
      mtidDescStoreCombine2 := TRegMultiString.Create( 'mtidDescStoreCombine2', 'to serve %d customers maximum' );

      // Alerts
      mtidFacilityWillBeDemolished := TRegMultiString.Create( 'mtidFacilityWillBeDemolished', 'ATTENTION! THE MAYOR OF %s REQUESTED THE DEMOLITION OF THIS BUILDING DUE TO CITY PLANNING. DEMOLITION WILL TAKE PLACE IN %d MONTHS. THE IFEL WILL PAY YOU %s AS A COMPENSATION.' );

      // Curriculum
      mtidOwnershipReport   := TRegMultiString.Create( 'mtidOwnershipReport', 'Controls %d companies, %d facilities, %d tiles in the map (%s in land taxes).' );
      mtidResearchReport    := TRegMultiString.Create( 'mtidResearchReport', '%d completed research items.' );
      mtidWonElections      := TRegMultiString.Create( 'mtidWonElections', 'Was elected Mayor of %s in the campaign of %d.' );
      mtidWasMayor          := TRegMultiString.Create( 'mtidWasMayor', 'Was Mayor of %s from %d to %d with a %d%% of popular rating.' );
      mtidWasFiredFromMayor := TRegMultiString.Create( 'mtidWasFiredFromMayor', 'Was fired from Mayor of %s in %d.' );
      mtidWasPresident      := TRegMultiString.Create( 'mtidWasPresident', 'Was President of %s from %d to %d with a %d%% of popular rating.' );
      mtidWonWorldElections := TRegMultiString.Create( 'mtidWonWorldElections', 'Was elected President of %s in the campaign of %d.' );
      mtidWasMinister       := TRegMultiString.Create( 'mtidWasMinister', 'Was Minister of %s from %d to %d with a %d%% of IFEL rating.' );
      mtidAppointedMinister := TRegMultiString.Create( 'mtidAppointedMinister', 'Was appointed Minister of %s in the campaign of %d by %s.' );
      mtidBankrupt          := TRegMultiString.Create( 'mtidBankrupt', 'Was declared in bankrupty in %d' );
      mtidTranscended       := TRegMultiString.Create( 'mtidTransended', 'Transcended in %d' );

      // Levels
      mtidLevelAchieved                := TRegMultiString.Create( 'mtidLevelAchieved', 'Achieved level %s in %d' );
      mtidNotEnoughMoney               := TRegMultiString.Create( 'mtidNotEnoughMoney', 'Could not upgrade level last year. You failed to pay $%.0n' );
      mtidNotEnoughProfit              := TRegMultiString.Create( 'mtidNotEnoughProfit', 'Could not upgrade level last year. You require an average profit ratio of $%.0n/h (last year you had $%.0n/h)' );
      mtidMustHaveBeenMayor            := TRegMultiString.Create( 'mtidMustHaveBeenMayor', 'You need to be elected Mayor at least once' );
      mtidMustHaveBeenPresident        := TRegMultiString.Create( 'mtidMustHaveBeenPresident', 'You need to be elected President at least once' );
      mtidPrestigeRequired             := TRegMultiString.Create( 'mtidPrestigeRequired', 'Could not upgrade level last year. You require %d prestige points' );
      mtidNotEnoughPrestigeLostLevel   := TRegMultiString.Create( 'mtidNotEnoughPrestigeLostLevel', 'Lost level %s in %d. You didn''t have the required %d prestige points' );
      mtidNotEnoughProfitLostLevel     := TRegMultiString.Create( 'mtidNotEnoughProfitLostLevel', 'Lost level %s in %d. You didn''t have the required average profit ratio of $%.0n/h (last year you had $%.0n/h)' );
      mtidLevelLost                    := TRegMultiString.Create( 'mtidLevelLost', 'Lost level %s in %d.' );

      // Misc
      mtidJoinedWorld := TRegMultiString.Create( 'mtidJoinedWorld', 'Joined %s in %d' );
      mtidAND         := TRegMultiString.Create( 'mtidAND', 'and' );

      // Events
      mtidSetTaxes                  := TRegMultiString.Create( 'mtidSetTaxes', 'Mayor of %s set taxes for %s at %s%%.' );
      mtidSubsidy                   := TRegMultiString.Create( 'mtidSubsidy', 'Mayor of %s set a subsidy for %s.' );
      mtidLaunchedCampaign          := TRegMultiString.Create( 'mtidLaunchedCampaign', '%s launched a campaign for %s.' );
      mtidCancelledCampaign         := TRegMultiString.Create( 'mtidCancelledCampaign', '%s withdrawed campaign for %s' );
      mtidMayorElected              := TRegMultiString.Create( 'mtidMayorElected', '%s was elected Mayor of %s.' );
      mtidMayorReElected            := TRegMultiString.Create( 'mtidMayorReElected', '%s was reelected Mayor of %s.' );
      mtidCityHasNoMayor            := TRegMultiString.Create( 'mtidCityHasNoMayor', '%s has no Mayor.' );
      mtidMayorFired                := TRegMultiString.Create( 'mtidMayorFired', '%s was fired from Mayor of %s.' );
      mtidSubsidiesRemoved          := TRegMultiString.Create( 'mtidSubsidiesRemoved', '%s removed its subsidies. Population is already greater than 9,000.' );
      mtidTycoonBankrupt            := TRegMultiString.Create( 'mtidTycoonBankrupt', '%s was declared bankrupt.' );
      mtidFacBuilt                  := TRegMultiString.Create( 'mtidFacBuilt', '%s built %s near %s.' );
      mtidAccountReset              := TRegMultiString.Create( 'mtidAccountReset', '%s made an account reset.' );
      mtidMsgJoinedWorld            := TRegMultiString.Create( 'mtidMsgJoinedWorld', '%s joined %s.' );
      mtidSatelliteUpdated          := TRegMultiString.Create( 'mtidSatelliteUpdated', 'The satellite map of %s has been updated.' );
      mtidMinisterElected           := TRegMultiString.Create( 'mtidMinisterElected', '%s was appointed %s.' );
      mtidPresidentElected          := TRegMultiString.Create( 'mtidPresidentElected', '%s was elected President of %s' );
      mtidPresidentReElected        := TRegMultiString.Create( 'mtidPresidentReElected', '%s was reelected President of %s.' );
      mtidNoPresident               := TRegMultiString.Create( 'mtidNoPresident', '%s has no President.' );
      mtidPresidenCampaignLaunched  := TRegMultiString.Create( 'mtidPresidenCampaignLaunched', '%s launched a campaign for the Presidency of %s.' );
      mtidPresidenCampaignCancelled := TRegMultiString.Create( 'mtidPresidenCampaignCancelled', '%s withdrawed campaign for Presidency of %s.' );

      // Arrange later
      mtidCiviHQPrest          := TRegMultiString.Create( 'mtidCiviHQPrest', '%d prestige points from publicity.' );
      mtidPubFacMain           := TRegMultiString.Create( 'mtidPubFacMain', '%d%% operational.' );
      mtidCapitolMain          := TRegMultiString.Create( 'mtidCapitolMain', 'President: %s.' );
      mtidCapitolWithPresSec   := TRegMultiString.Create( 'mtidCapitolWithPresSec', 'President rated at %d%%. %d years to Elections.' );
      mtidCapitolWithNoPresSec := TRegMultiString.Create( 'mtidCapitolWithNoPresSec', 'No President. %d years to Elections.' );
      mtidCapitolHint          := TRegMultiString.Create( 'mtidCapitolHint', 'Hint: If you have more than 1000 prestige points you can launch your campaign for the presidency of %s.' );
      mtidTVMainOne            := TRegMultiString.Create( 'mtidTVMainOne', '%d viewers' );
      mtidTVMainTwo            := TRegMultiString.Create( 'mtidTVMainTwo', '%d%% rating' );
      mtidTVSec                := TRegMultiString.Create( 'mtidTVSec', 'Broadcasting %d hours a day. %d%% of commercials. %d%% of commercials time sold. %d antennas worldwide. TV Station quality: %d%%, efficiency: %d%%' );
      mtidHiringWorkForce      := TRegMultiString.Create( 'mtidHiringWorkForce', 'Hiring workforce at %d%%' );
      mtidHiringWorkForceSec   := TRegMultiString.Create( 'mtidHiringWorkForceSec', '%s: %d of %d.' );
      mtidTVWarning            := TRegMultiString.Create( 'mtidTVWarning', 'WARNING: There are no antennas attached to this facility. Use the Connect button in the INSPECT panel to connect an antenna.' );
      mtidAntenaAudience       := TRegMultiString.Create( 'mtidAntenaAudience', 'Potential audience: %d.' );
      mtidAntenaRating         := TRegMultiString.Create( 'mtidAntenaRating', 'Channel rating: %d%%.' );
      mtidAntenaHint           := TRegMultiString.Create( 'mtidAntenaHint', 'HINT: Use the "Connect" button in the INSPECT panel to connect this antenna to a station.' );
      mtidConstruction         := TRegMultiString.Create( 'mtidConstruction', '%d%% completed.' );
      mtidStoppedDueWeather    := TRegMultiString.Create( 'mtidStoppedDueWeather', 'Stopped due to weather conditions.' );
      mtidOfficeReport         := TRegMultiString.Create( 'mtidOfficeReport', '%d offices rented. %d quality index. BAP: %d%%. Beauty: %d%%. Crime: %d%%. Pollution %d%%.' );
      mtidOfficeTitle          := TRegMultiString.Create( 'mtidOfficeTitle', 'Office Building' );
      mtidOfficeOccup          := TRegMultiString.Create( 'mtidOfficeOccup', '%d%% of offices rented' );
      mtidWarehouseRepHead     := TRegMultiString.Create( 'mtidWarehouseRepHead', 'Storing:' );
      mtidWarehouseRepN        := TRegMultiString.Create( 'mtidWarehouseRepN', '%s of %s at %d%% qualiy index.' );
      mtidMinisterName         := TRegMultiString.Create( 'mtidMinisterName', 'Minister of %s' );
      mtidMinistryName         := TRegMultiString.Create( 'mtidMinistryName', 'Ministry of %s' );
      mtidCommerceMain         := TRegMultiString.Create( 'mtidCommerceMain', '%s sales at %d%%' );
      mtidOutputEvalFull       := TRegMultiString.Create( 'mtidOutputEvalFull', '%s production: %d%%' );
      mtidOutputEval           := TRegMultiString.Create( 'mtidOutputEval', 'Producing: %d%%' );
      mtidOutputSec            := TRegMultiString.Create( 'mtidOutputSec', '%s of %s at %d%% quality index, %d%% efficiency' );
      mtidInvPrice             := TRegMultiString.Create( 'mtidInvPrice', 'Price: %s' );
      mtidInvLicense           := TRegMultiString.Create( 'mtidInvLicense', 'License: %s' );
      mtidInvImpCostYear       := TRegMultiString.Create( 'mtidInvImpCostYear', 'Implementation: %s a year/fac' );
      mtidInvImpCostHour       := TRegMultiString.Create( 'mtidInvImpCostHour', 'Implementation: %s/hour' );
      mtidInvUsage             := TRegMultiString.Create( 'mtidInvUsage', 'Facilities: %d' );
      mtidInvNobPoints         := TRegMultiString.Create( 'mtidInvNobPoints', 'Nobility: %s pts' );
      mtidInvPrestige          := TRegMultiString.Create( 'mtidInvPrestige', 'Prestige: %s pts' );
      mtidInvLevel             := TRegMultiString.Create( 'mtidInvLevel', 'Level: %s' );
      mtidInvPayReduct         := TRegMultiString.Create( 'mtidInvPayReduct', 'Payroll reduction: %s%%' );
      mtidInvJobQ              := TRegMultiString.Create( 'mtidInvJobQ', 'Job quality: %s%%' );
      mtidInvBeauty            := TRegMultiString.Create( 'mtidInvBeauty', 'Beauty: %s%%' );
      mtidInvMaintenance       := TRegMultiString.Create( 'mtidInvMaintenance', 'Maintenance: %s%%' );
      mtidInvPrivacy           := TRegMultiString.Create( 'mtidInvPrivacy', 'Privacy: %s%%' );
      mtidInvCrimeRes          := TRegMultiString.Create( 'mtidInvCrimeRes', 'Security: %s%%' );
      mtidInvPollRes           := TRegMultiString.Create( 'mtidInvPollRes', 'Environment: %s%%' );
      mtidInvEff               := TRegMultiString.Create( 'mtidInvEff', 'Efficiency: %s%%' );
      mtidInvDesirability      := TRegMultiString.Create( 'mtidInvDesirability', 'Desirability: %s pts' );
      mtidInvQ                 := TRegMultiString.Create( 'mtidInvQ', 'Quality: %s pts' );

      mtidOfficeClone          := TRegMultiString.Create( 'mtidOfficeClone', 'Rent|%d|Maintenance|%d|' );

      mtidPlayerWillTranscend := TRegMultiString.Create( 'mtidPlayerWillTranscend', 'Estimated date of Transcendence: %d days.' );
      mtidBewareOfTranscend   := TRegMultiString.Create( 'mtidBewareOfTranscend', 'WARNING! All facilities belonging to %s will disappear except this building. This may affect your facilities in this world.' );

      mtidGrowingTrees        := TRegMultiString.Create( 'mtidGrowingTrees', 'Growing trees at %d%%' );

      mtidLicensingFilm       := TRegMultiString.Create('mtidLicensingFilm', 'Licensing: "%s"  Quality Index: %d%%.');
      mtidFilmProject         := TRegMultiString.Create('mtidFilmProject', 'Filming: "%s" Day %d of %d, %d%% done.');
      mtidNowPlaying          := TRegMultiString.Create('mtidNowPlaying', 'Now playing:');

      mtidInvCatGeneral       := TRegMultiString.Create('mtidInvCatGeneral', 'General');
      mtidInvCatCommerce      := TRegMultiString.Create('mtidInvCatCommerce', 'Commerce');
      mtidInvCatIndustry      := TRegMultiString.Create('mtidInvCatIndustry', 'Industry');
      mtidInvCatRlEstate      := TRegMultiString.Create('mtidInvCatRlEstate', 'Real Estate');

    end;

initialization

  InitMLS;

end.
