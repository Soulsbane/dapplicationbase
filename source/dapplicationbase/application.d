/**
	A simple wrapper for creating a command line application.
*/
module dapplicationbase.application;

public import std.path : buildNormalizedPath;
import std.stdio;

public import dpathutils.config;
public import ctoptions;

import dapplicationbase.settings;

private struct OptionsBase {}

class Application(AppOptions = OptionsBase) : GetOptCodeGenerator!(AppOptions, No.generateHelperMethods)
{
public:

		/**
		Creates a new application.

		Params:
			organizationName = Name of the organization/company. This is used for creating a folder inside
				users config directory using the specified name. Note: Can pass a empty string.
			applicationName = Name of the application. This will be used for creating a folder inside user's
				config/<orgranizationName>/<applicationName>
			arguments = The application's command line arguments.

	*/
	void create(const string organizationName, const string applicationName, string[] arguments,
		const Flag!"createDirs" createDirs = Yes.createDirs)
	{
		settings_.create(organizationName, applicationName, createDirs);

		loadOptions();
		handleCmdLineArguments(arguments);
		onCreate();
	}

	/**
		Used for notifying the inherited class that the basic application setup is completed.
	*/
	void onCreate() {}

	/**
		Loads the StructOptions config file.
	*/
	bool loadOptions()
	{
		immutable string fileName = buildNormalizedPath(settings_.getAppConfigDir("config"), "app.config");
		settings_.createDefaultFile(fileName);
		return settings_.loadFile(fileName);
	}

	/**
		Saves the StructOptions config file.
	*/
	void saveOptions()
	{
		immutable string fileName = buildNormalizedPath(path_.getAppConfigDir("config"), "app.config");
		options_.save(fileName);
	}

	/**
		Generates getopt code using ctoptions.getoptmixin module.
	*/
	void handleCmdLineArguments(string[] arguments)
	{
		generate(arguments, settings_.Options);
	}

	Settings!AppOptions settings_;
	alias settings_ this;
}
