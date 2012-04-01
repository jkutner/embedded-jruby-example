require 'java'

java_import "javax.script.ScriptContext"
java_import "javax.script.ScriptEngine"
java_import "javax.script.ScriptEngineManager"
java_import "javax.script.ScriptException"
java_import "java.io.FileNotFoundException"
java_import "javax.script.Bindings"
java_import "javax.script.SimpleBindings"
java_import "java.io.FileReader"
java_import "java.io.Reader"

def create_jruby_engine
  # this means that we take all responsibility for concurrency
  java.lang.System.setProperty("org.jruby.embed.localcontext.scope", 'singlethread')

  m = ScriptEngineManager.new()
  e = m.getEngineByName("jruby")

  bindings = SimpleBindings.new()
  #bindings.put("RACK_ENV", ENV['RACK_ENV'])

  yield e, bindings

  e
end

def eval_file(engine, relative_path, bindings)
  file = File.expand_path(relative_path, __FILE__)
  reader = FileReader.new(file)
  engine.eval(reader, bindings)
end

def load_gems(engine, gems)
  s = gems ? gems.map do |gem|
    gem_name = gem.gsub(/ (\(.+\))?\z/, "").strip
    version = gem =~ /\((.*\s?.+)\)\z/ ? $1 : ">= 0"
    "gem '#{gem_name}', '#{version}'; require '#{gem_name}'; "
  end : []
  engine.eval("begin; #{s.join('; ')} rescue => e; puts e.message; end")
end

e = create_jruby_engine do |e, bindings|  
  eval_file(e, "../boot.rb", bindings)
  load_gems(e, ["rack"])

  puts 'gems loaded'

  code = "begin; Rack::Builder.parse_file('config.ru')[0]; rescue => e; puts e.message; end"
  begin
    e.eval(code, bindings) #.call(env)

    puts "code evaled"
  rescue => e
    puts "Dead ;)\n\n#{e.message}\n\n\t#{e.backtrace.join("\n\t")}"
  end
end