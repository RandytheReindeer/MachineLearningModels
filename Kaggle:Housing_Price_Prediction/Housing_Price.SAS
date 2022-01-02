Proc Import Datafile='/home/u58297693/Stat1/train.csv' Out=Train 
		Replace;
Run;

Proc Print Data=Train;
Run;

/* Importing the Testing Data Set from Kaggle */
Proc Import Datafile='/home/u58297693/Stat1/test.csv' Out=Test 
		Replace;
Run;

Proc Print Data=Test;
Run;

/* Shortening the data to the 3 Neighborhoods of interest; NAmes, BrkSide, Edwards*/
Data TrainNeighborhood;
	Set Train;
	Where Neighborhood='NAmes' OR Neighborhood='BrkSide' OR Neighborhood='Edwards';
Run;

Proc Print Data=TrainNeighborhood;
Run;

/* Proc GLM to check the Assumptions */
/* Simple Model on Full Data*/
Proc GLM Data=TrainNeighborhood Plots=All;
	Model SalePrice=GrLivArea/ solution;
	Run;

	/* It appears that there are 4 outliers, 2 with large GrLivArea and 2 with large SalePrice */
	/* The outliers are observation 643, 725, 1299, and 524 */
	/* Removing the Outliers */
Data TrainNoOutlier;
	Set TrainNeighborhood;
	Where Id ~=643 AND Id ~=725 AND Id ~=1299 AND Id ~=524;
Run;

Proc Print Data=TrainNoOutlier;
Run;

/* Proc GLM to check Assumptions with No Ouliers */
/* Also Shows the simple linear model on No Outlier Data */
Proc GLM Data=TrainNoOutlier Plots=All;
	Model SalePrice=GrLivArea/ Solution clm;
	Run;
	
Proc reg Data=TrainNoOutlier;
	Model SalePrice=GrLivArea/ clb;
	Run;

	/* Simple Model NO INTERCEPT on All Data (would not use this) */
Proc GLM Data=TrainNeighborhood Plots=All;
	Model SalePrice=GrLivArea/ noint solution;
	Run;

	/* Simple Model NO INTERCEPT on No Outlier Data */
Proc GLM Data=TrainNoOutlier Plots=All;
	Model SalePrice=GrLivArea/ noint solution;
	Run;

	/* Proc GLM showing the Full Model on All Data */
Proc GLM Data=TrainNeighborhood Plots=ALL;
	Class Neighborhood (ref='NAmes');
	Model SalePrice=GrLivArea Neighborhood/ Solution;
	Run;

	/* Proc GLM showing Full Model on No Outlier Data */
Proc GLM Data=TrainNoOutlier Plots=All;
	Class Neighborhood (ref='NAmes');
	Model SalePrice=GrLivArea Neighborhood/ Solution clm;
	Run;

	/* Pric GLM Showing Full Model on All Data with NO INTERCEPT */
Proc GLM Data=TrainNeighborhood Plots=All;
	Class Neighborhood (ref='NAmes');
	Model SalePrice=GrLivArea Neighborhood/ noint solution;
	Run;

	/* Proc GLM showing Full Model on No Outlier Data with NO INTERCEPT */
Proc GLM Data=TrainNoOutlier Plots=ALL;
	Class Neighborhood (ref='NAmes');
	Model SalePrice=GrLivArea Neighborhood/ noint solution;
	Run;

	/* Proc GLM showing Reduced Model on All Data */
Proc GLM Data=TrainNeighborhood Plots=ALL;
	Class Neighborhood (ref='NAmes');
	Model SalePrice=GrLivArea | Neighborhood/ Solution;
	Run;

	/* Proc GLM showing Reduced Model on No Outlier Data */
	/* Chosen Model! */
Proc GLM Data=TrainNoOutlier Plots=All;
	Class Neighborhood (ref='NAmes');
	Model SalePrice=GrLivArea | Neighborhood/ Solution clparm clm;
	Run;

	/* Proc GLM showing Reduced Model on All Data with NO INTERCEPT */
Proc GLM Data=TrainNeighborhood Plots=ALL;
	Class Neighborhood (ref='NAmes');
	Model SalePrice=GrLivArea | Neighborhood/ noint solution;
	Run;

	/* Proc GLM showing Reduced Model on No Outlier Data with NO INTERCEPT */
Proc GLM Data=TrainNoOutlier PLots=All;
	Class Neighborhood (ref='NAmes');
	Model SalePrice=GrLivArea | Neighborhood/ noint solution;
	Run;

	/* End Analysis Question 1 */
	/* Start Analysis Question 2 */
	/* Adding the variable SalePrice to the Test data set */
Data Test;
	Set Test;
	SalePrice=.;
Run;

/* Adding the Train and Test set together to get the estimates */
/* No Outliers */
Data TrainNoOutlier2;
	Set Train;
	Where Id ~=643 AND Id ~=725 AND Id ~=1299 AND Id ~=524;
Run;

Proc Print Data=TrainNoOutlier2;
Run;

/* Adding the Train and Test set together to get the estimates */
Data TestEst2;
	Set TrainNoOutlier2 Test;
Run;

/* Forward Selection */
Proc GLMSelect Data=TrainNoOutlier2;
	Class MSSubClass MSZoning Street Alley LotShape LandContour Utilities 
		LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle 
		OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle RoofMatl Exterior1st 
		Exterior2nd MasVnrType ExterQual ExterCond Foundation BsmtQual BsmtCond 
		BsmtExposure BsmtFinType1 BsmtFinType2 Heating HeatingQC CentralAir 
		Electrical BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr 
		KitchenAbvGr KitchenQual TotRmsAbvGrd Functional Fireplaces FireplaceQu 
		GarageType GarageYrBlt GarageFinish GarageCars GarageQual GarageCond 
		PavedDrive PoolQC Fence MiscFeature MoSold YrSold SaleType SaleCondition 
		LotFrontage;
	model SalePrice=MSSubClass MSZoning LotFrontage LotArea Street Alley LotShape 
		LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 
		BldgType HouseStyle OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle 
		RoofMatl Exterior1st Exterior2nd MasVnrType MasVnrArea ExterQual ExterCond 
		Foundation BsmtQual BsmtCond BsmtExposure BsmtFinType1 BsmtFinSF1 
		BsmtFinType2 BsmtFinSF2 BsmtUnfSF TotalBsmtSF Heating HeatingQC CentralAir 
		Electrical LowQualFinSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath 
		BedroomAbvGr KitchenAbvGr KitchenQual TotRmsAbvGrd Functional Fireplaces 
		FireplaceQu GarageType GarageYrBlt GarageFinish GarageCars GarageArea 
		GarageQual GarageCond PavedDrive WoodDeckSF OpenPorchSF EnclosedPorch 
		ScreenPorch PoolArea PoolQC Fence MiscFeature MoSold YrSold SaleType 
		SaleCondition/ selection=FORWARD(stop=cv) cvmethod=random(5) stats=ADJRSQ;
Run;

/* Getting estimates using the forward selection equation */
Proc GLM Data=TestEst2 plots=ALL;
	Class Neighborhood OverallQual MSSubClass SaleCondition KitchenQual FullBath 
		BsmtExposure OverallCond GarageCars;
	Model SalePrice=OverallQual GrLivArea BsmtFinSF1 MSSubClass SaleCondition 
		LotArea KitchenQual TotalBsmtSF FullBath Neighborhood BsmtExposure 
		OverallCond GarageCars PoolArea/ cli solution;
	Output out=resultsF2 p=Predict;
	Run;

	/* Creating the data set with just the predictions from forward selection*/
Data resultsforward2;
	Set resultsF2;

	If Predict > 0 then
		SalePrice=Predict;

	If Predict < 0 then
		SalePrice=163000;
	Keep Id SalePrice;
	Where Id > 1460;
Run;

Proc Print Data=resultsforward2;
Run;

/* export data */
proc export data = resultsforward2
outfile='/home/u58297693/Stat1/resultsforward2.csv'
dbms=csv;
run;


/* Backward Elimination */
Proc GLMSelect Data=TrainNoOutlier2;
	Class MSSubClass MSZoning Street Alley LotShape LandContour Utilities 
		LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle 
		OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle RoofMatl Exterior1st 
		Exterior2nd MasVnrType ExterQual ExterCond Foundation BsmtQual BsmtCond 
		BsmtExposure BsmtFinType1 BsmtFinType2 Heating HeatingQC CentralAir 
		Electrical BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr 
		KitchenAbvGr KitchenQual TotRmsAbvGrd Functional Fireplaces FireplaceQu 
		GarageType GarageYrBlt GarageFinish GarageCars GarageQual GarageCond 
		PavedDrive PoolQC Fence MiscFeature MoSold YrSold SaleType SaleCondition 
		LotFrontage;
	model SalePrice=MSSubClass MSZoning LotFrontage LotArea Street Alley LotShape 
		LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 
		BldgType HouseStyle OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle 
		RoofMatl Exterior1st Exterior2nd MasVnrType MasVnrArea ExterQual ExterCond 
		Foundation BsmtQual BsmtCond BsmtExposure BsmtFinType1 BsmtFinSF1 
		BsmtFinType2 BsmtFinSF2 BsmtUnfSF TotalBsmtSF Heating HeatingQC CentralAir 
		Electrical LowQualFinSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath 
		BedroomAbvGr KitchenAbvGr KitchenQual TotRmsAbvGrd Functional Fireplaces 
		FireplaceQu GarageType GarageYrBlt GarageFinish GarageCars GarageArea 
		GarageQual GarageCond PavedDrive WoodDeckSF OpenPorchSF EnclosedPorch 
		ScreenPorch PoolArea PoolQC Fence MiscFeature MoSold YrSold SaleType 
		SaleCondition/ selection=BACKWARD(stop=cv) cvmethod=random(5) stats=ADJRSQ;
Run;

/* Getting estimates using the backward elimination equation */
Proc GLM Data=TestEst2 Plots=ALL;
	Class MSSubClass MSZoning Street Alley LotShape LandContour Utilities 
		LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle 
		OverallQual OverallCond YearRemodAdd RoofStyle RoofMatl Exterior1st 
		Exterior2nd MasVnrType ExterQual ExterCond Foundation BsmtQual BsmtCond 
		BsmtExposure BsmtFinType1 BsmtFinType2 Heating HeatingQC CentralAir 
		Electrical BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr 
		KitchenAbvGr KitchenQual TotRmsAbvGrd Functional Fireplaces FireplaceQu 
		GarageType GarageYrBlt GarageFinish GarageCars GarageQual GarageCond 
		PavedDrive PoolQC Fence MiscFeature MoSold YrSold SaleType SaleCondition 
		LotFrontage;
	model SalePrice=MSSubClass MSZoning LotFrontage LotArea Street Alley LotShape 
		LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 
		BldgType HouseStyle OverallQual OverallCond YearRemodAdd RoofStyle RoofMatl 
		Exterior1st Exterior2nd MasVnrType MasVnrArea ExterQual ExterCond Foundation 
		BsmtQual BsmtCond BsmtExposure BsmtFinType1 BsmtFinSF1 BsmtFinType2 
		BsmtFinSF2 BsmtUnfSF Heating HeatingQC CentralAir Electrical LowQualFinSF 
		GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr 
		KitchenAbvGr KitchenQual TotRmsAbvGrd Functional Fireplaces FireplaceQu 
		GarageType GarageYrBlt GarageFinish GarageCars GarageArea GarageQual 
		GarageCond PavedDrive WoodDeckSF OpenPorchSF EnclosedPorch ScreenPorch 
		PoolArea PoolQC Fence MiscFeature MoSold YrSold SaleType SaleCondition/ cli 
		solution;
	Output out=resultsB p=Predict;
	Run;

	/* Creating the data set with just the predictions from backward elimination*/
Data resultsbackward;
	Set resultsB;

	If Predict > 0 then
		SalePrice=Predict;

	If Predict < 0 then
		SalePrice=163000;
	Keep Id SalePrice;
	Where Id > 1460;
Run;

Proc Print Data=resultsbackward;
Run;

proc export data = resultsbackward
outfile='/home/u58297693/Stat1/resultsbackward.csv'
dbms=csv;
run;

/* Stepwise Selection */
Proc GLMSelect Data=TrainNoOutlier2;
	Class MSSubClass MSZoning Street Alley LotShape LandContour Utilities 
		LotConfig LandSlope Neighborhood Condition1 Condition2 BldgType HouseStyle 
		OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle RoofMatl Exterior1st 
		Exterior2nd MasVnrType ExterQual ExterCond Foundation BsmtQual BsmtCond 
		BsmtExposure BsmtFinType1 BsmtFinType2 Heating HeatingQC CentralAir 
		Electrical BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr 
		KitchenAbvGr KitchenQual TotRmsAbvGrd Functional Fireplaces FireplaceQu 
		GarageType GarageYrBlt GarageFinish GarageCars GarageQual GarageCond 
		PavedDrive PoolQC Fence MiscFeature MoSold YrSold SaleType SaleCondition 
		LotFrontage;
	model SalePrice=MSSubClass MSZoning LotFrontage LotArea Street Alley LotShape 
		LandContour Utilities LotConfig LandSlope Neighborhood Condition1 Condition2 
		BldgType HouseStyle OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle 
		RoofMatl Exterior1st Exterior2nd MasVnrType MasVnrArea ExterQual ExterCond 
		Foundation BsmtQual BsmtCond BsmtExposure BsmtFinType1 BsmtFinSF1 
		BsmtFinType2 BsmtFinSF2 BsmtUnfSF TotalBsmtSF Heating HeatingQC CentralAir 
		Electrical LowQualFinSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath 
		BedroomAbvGr KitchenAbvGr KitchenQual TotRmsAbvGrd Functional Fireplaces 
		FireplaceQu GarageType GarageYrBlt GarageFinish GarageCars GarageArea 
		GarageQual GarageCond PavedDrive WoodDeckSF OpenPorchSF EnclosedPorch 
		ScreenPorch PoolArea PoolQC Fence MiscFeature MoSold YrSold SaleType 
		SaleCondition/ selection=Stepwise(stop=cv) cvmethod=random(5) stats=ADJRSQ;
Run;

/* Getting estimates using the Stepwise selection equation */
Proc GLM Data=TestEst2 plots=all;
	Class MSSubClass Neighborhood OverallQual OverallCond BsmtExposure FullBath 
		KitchenQual GarageCars SaleCondition;
	model SalePrice=OverallQual GrLivArea BsmtFinSF1 MSSubClass SaleCondition 
		LotArea KitchenQual TotalBsmtSF FullBath Neighborhood BsmtExposure 
		OverallCond GarageCars/ cli solution;
	Output out=resultsS2 p=Predict;
	Run;

	/* Creating the data set with just the predictions from stepwise selection*/
Data resultsstepwise2;
	Set resultsS2;

	If Predict > 0 then
		SalePrice=Predict;

	If Predict < 0 then
		SalePrice=163000;
	Keep Id SalePrice;
	Where Id > 1460;
Run;

Proc Print Data=resultsstepwise2;
Run;

proc export data = resultsstepwise2
outfile='/home/u58297693/Stat1/resultsstepwise2.csv'
dbms=csv;
run;

/* Custom Model */
Proc GLM Data=TestEst2 Plots=All;
	Class Neighborhood (ref='BrDale') OverallQual (ref='2');
	Model SalePrice=Neighborhood OverallQual GrLivArea/ cli solution;
	Output out=resultsC p=Predict;
	Run;

	/* Creating the data set with just the predictions from stepwise selection*/
Data resultscustom;
	Set resultsC;

	If Predict > 0 then
		SalePrice=Predict;

	If Predict < 0 then
		SalePrice=163000;
	Keep Id SalePrice;
	Where Id > 1460;
Run;

Proc Print Data=resultscustom;
Run;

proc export data = resultscustom
outfile='/home/u58297693/Stat1/resultscustom.csv'
dbms=csv;
run;
