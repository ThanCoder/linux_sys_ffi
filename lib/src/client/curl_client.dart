import 'dart:io';

/// Curl ရဲ့ လုပ်ဆောင်ချက်များကို စီမံခန့်ခွဲမည့် Class
class CurlClient {
  final List<String> _arguments = [];

  ///-s, --silent
  ///Silent mode
  CurlClient setSilent(bool silent) {
    if (silent) {
      _arguments.add('--silent');
    }
    return this;
  }

  ///-i, --include
  ///
  ///Include protocol response headers in the output
  CurlClient setIncludeHeaders(bool include) {
    if (include) {
      _arguments.add('--include');
    }
    return this;
  }

  ///-A, --user-agent `<name>`
  ///
  ///Send User-Agent `<name>` to server
  CurlClient setUserAgent(String agent) {
    _arguments.add('--user-agent $agent');
    return this;
  }

  ///-v, --verbose
  ///Make the operation more talkativ
  CurlClient get verbose {
    _arguments.add('--verbose');
    return this;
  }

  ///-d, --data <data>
  ///HTTP POST data
  CurlClient postData(String data) {
    _arguments.add('--data $data');
    return this;
  }

  ///-f, --fail
  ///
  ///Fail fast with no output on HTTP errors
  CurlClient setFailNoOutput(bool noOutput) {
    if (noOutput) {
      _arguments.add('--fail');
    }
    return this;
  }

  ///-T, --upload-file `<file>`
  ///
  ///Transfer local FILE to destination
  CurlClient uploadFile(String filePath) {
    _arguments.add('--upload-file $filePath');
    return this;
  }

  ///-u, --user `<user:password>`
  ///
  ///Server user and password
  CurlClient userAndPassword(String username, String password) {
    _arguments.add('--user $username:$password');
    return this;
  }

  ///-O, --remote-name
  ///
  ///Write output to a file named as the remote file
  CurlClient setRemoteName(bool showRemoteName) {
    if (showRemoteName) {
      _arguments.add('--remote-name');
    }
    return this;
  }

  ///-V, --version
  ///
  /// Show version number and quit
  void get version {
    _arguments.add('--version');
  }

  /// URL တစ်ခုဆီသို့ GET Request ပို့မည့် Method
  Future<String> get(String url) async {
    _arguments.add(url);
    return await run();
  }

  /// ### Exec Command
  Future<String> run() async {
    try {
      // Dart Process သုံးပြီး curl ကို လှမ်းခေါ်ခြင်း
      ProcessResult result = await Process.run('curl', _arguments);

      if (result.exitCode == 0) {
        return result.stdout.toString();
      } else {
        throw Exception(result.stderr);
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
