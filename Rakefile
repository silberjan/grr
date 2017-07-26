task default: %w[all]

task :test do
  ruby "test/main.rb"
end

task :all => [:test, :grrbenchmark, :httpbenchmark] do
    puts "Ready!"
end

task :grrbenchmark do
  ruby "benchmarks/benchmark_grr.rb"
end

task :httpbenchmark do
  ruby "benchmarks/benchmark_http.rb"
end
