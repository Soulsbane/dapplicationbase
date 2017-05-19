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

private interface EmptyBase {}
private struct OptionsBase {}

mixin template ApplicationMixin(AppOptions = OptionsBase, InheritedClass = EmptyBase)
{
	/**
		A simple class for creating a command line application. Much of the functionality is pulled from
		ctoptions library. Specifically structoptions and getoptmixin.
	*/
	class Application : InheritedClass
	{
	public:
		this()
		{
			// We have to jump through a bunch of hoops here since D doesn't support multiple inheritance.
			getOptGen_ = new GetOptCodeGenerator!(AppOptions);

			getOptGen_.setCallback!"onNoArguments"(&onNoArguments);
			getOptGen_.setCallback!"onHelp"(&onHelp);
			getOptGen_.setCallback!"onValidArguments"(&onValidArguments);
			getOptGen_.setCallback!"onUnknownArgument"(&onUnknownArgument);
			getOptGen_.setCallback!"onInvalidArgument"(&onInvalidArgument);
		}

		// We have to reimplement these callbacks since alias this doesn't support override of a member function
		// in the inherited class.

		/**
			Called when no arguments are passed to the command line.
		*/
		void onNoArguments() {}

		/**
			Called when --help is passed to the command line.
		*/
		void onHelp(Option[] options)
		{
			defaultGetoptPrinter("The following options are available:", options);
		}

		/**
			Called when all arguments containing no errors are passed to the command line.
		*/
		void onValidArguments() {}

		/**
			Called when an argument is missing it's value. Example: <applicationName> --id=10 but the 10 is left out.
		*/
		void onUnknownArgument(const string msg)
		{
			writeln(msg, ". For a list of available commands use --help.");
		}

		/**
			Called when an argument is passed a wrong type. Example: int id; --id=hello
		*/
		void onInvalidArgument(const string msg)
		{
			writeln("Invalid Argument!");
			writeln(msg);
		}

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
			getOptGen_.generate(arguments, options_);
		}

		/**
			Allows callback methods in GetOptCodeGenerator to be overridden.

			Params:
				name = Name of the callback to override.
				callback = the callback function/method to use.
		*/
		void setCallback(alias name, Func)(Func callback)
		{
			getOptGen_.setCallback!name(callback);
		}

	public alias getOptGen_ this;

	protected:
		ConfigPath path_;
		StructOptions!AppOptions options_;
		GetOptCodeGenerator!(AppOptions) getOptGen_;
	}
}
