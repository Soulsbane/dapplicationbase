/**
	A simple wrapper for creating a command line application.
*/
module dapplicationbase.application;

public import std.path : buildNormalizedPath;
public import std.stdio;

public import dpathutils.config;
public import ctoptions.getoptmixin;
public import ctoptions.structoptions;
public import std.getopt;

private struct OptionsBase {}

	/**
		A simple class for creating a command line application. Much of the functionality is pulled from
		ctoptions library. Specifically structoptions and getoptmixin.
	*/
	class Application(AppOptions = OptionsBase) : GetOptCodeGenerator!AppOptions
	{
	public:

		/**
			Creates a new application.

			Params:
				organizationName = Name of the organization/company. This is used for creating a folder inside
					users config directory using the specified name. Note: Can pass a empty string.
				applicationName = Name of the application. This will be used for creating a folder inside user's
					config/<orgranizationName>/<applicationName>

		*/
		void create(const string organizationName, const string applicationName)
		{
			path_.create(organizationName, applicationName);
			createConfigDirs("config");
			loadOptions();
		}

		/**
			Creates a directory or directories in the user's config/<applicationName> directory.

			Params:
				A list of directories to create.
		*/
		void createConfigDirs(T...)(T dirs)
		{
			path_.createDir(dirs);
		}

		/**
			Loads the StructOptions config file.
		*/
		void loadOptions()
		{
			immutable string fileName = buildNormalizedPath(path_.getDir("config"), "app.config");

			options_.createDefaultFile(fileName);
			options_.loadFile(fileName);
		}

		/**
			Saves the StructOptions config file.
		*/
		void saveOptions()
		{
			immutable string fileName = buildNormalizedPath(path_.getDir("config"), "app.config");
			options_.save(fileName);
		}

		/**
			Generates getopt code using ctoptions.getoptmixin module.
		*/
		void handleCmdLineArguments(string[] arguments)
		{
			generate(arguments, options_);
		}

	protected:
		ConfigPath path_;
		StructOptions!AppOptions options_;
	}
