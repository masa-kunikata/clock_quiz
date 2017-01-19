module ClockQuiz
  module_function
  def process(setting)
    rnd = Random.new
    
    hour_seq   = (setting['min_hour']..setting['max_hour']).to_a
    minute_seq = (0..59).to_a.each_slice(setting['minute_unit']).to_a.map{|ms| ms.first}
    answer_ok_color = setting['answer_ok_color'] || 'lightgreen'
    
    randam_hm = ->{
      h = hour_seq[rnd.rand(hour_seq.size)]
      m = minute_seq[rnd.rand(minute_seq.size)]
      [h, m]
    }
    
    jp_minute_counter = ->(minute){
      return 'ふん' if minute == 0
      return 'ぷん' if [0, 1, 3, 6, 8].include?(minute % 10)
      'ふん'
    }
    format_time = ->(hour, minute){
      return "#{hour} じ" if 0 == minute
      "#{hour} じ #{minute} #{jp_minute_counter[minute]}"
    }
    
    qs = setting['quiz_count'].times.map do
      answer = randam_hm[] #答え
      
      selections = [] # 選択肢
      1000.times do
        selections.clear
        (setting['selection_count'] - 1).times do
          selections << randam_hm[]
        end
        selections << answer
        next if selections.map{|h, m| [(12 <= h ? h - 12 : h), m]}.uniq.size != setting['selection_count']
        break
      end

      selections.shuffle!
      selections.sort! if setting['selection_sort']
    
      {
        answer: answer,
        selections: selections,
      }
    end
    qs.sort! {|a, b| a[:answer] <=> b[:answer]} if setting['quiz_sort']

    out_file = if setting['file_path_proc']
      eval(setting['file_path_proc'])[]
    else
      'test.html'
    end
    
    require 'yaml'
    require 'erb'
    File.open(out_file, 'w') do |f|
      f.write(ERB.new(<<~EOS).result(binding))
        <!DOCTYPE html>
        <html>
        <head>
        <title>tokei_quiz</title>
        <style>
        .question td {
          vertical-align: top;
          line-height: 1.5em;
        }
        .question {
          float: left;
        }
        </style>
        <script src='js/canvas_clock.js'></script>
        <script>
        /*正答選択時のイベント登録*/
        function registerAnswerOkEvents(num){
          var question = document.getElementById('q' + num);
          var answer = document.getElementById('a' + num);
          answer.addEventListener('change', function(){
           question.style['background-color'] = answer.checked ? '<%= answer_ok_color %>' : 'white';
          });
          question.addEventListener('click', function(){
           if(answer.checked) return;
           question.style['background-color'] = 'white';
          });
        }
        </script>
        </head>
        <body>
         <% qs.each.with_index do |q, i| %>
          <table class='question' id="q<%= i + 1 %>">
            <tr>
              <td>
               <span id="s<%= i + 1 %>">■もんだい [<%= i + 1 %>]</span><br /><br />
               <% q[:selections].each.with_index do |s, n| %>
                <label>
                  <input type="radio" name="r<%= i + 1 %>" value="<%= '%02d:%02d' % s %>"
                    <% if s == q[:answer] then %>
                      id="a<%= i + 1 %>"
                    <% end %>
                  >
                  (<%= n + 1 %>) &nbsp; <%= format_time[*s] %>
                </label><br />
               <% end %>
               <script>registerAnswerOkEvents('<%= i + 1 %>');</script>
              </td>
              <td>
                <canvas id="c<%= i %>"></canvas>
                <script>clock('c<%= i %>', '<%= '%02d:%02d' % q[:answer] %>');</script>
              </td>
            </tr>
          </table>
         <% end %>
        <hr style='clear:both;'/>
        <table>
        <tr>
          <td>
            <canvas id="current"></canvas>
            <script>setInterval(currentClock, 1000, 'current', {size: 100, fontSize: 10, displaySecond: true});</script>
          </td>
          <td>
            <pre>
              <%= setting.to_yaml %>
            </pre>
          </td>
        </tr>
        </body>
        </html>
      EOS
    end
    
  end
end

if __FILE__ == $0
  exit false if ARGV.empty?

  ARGV.each do |def_file|
    next unless FileTest::exist?(def_file)

    require 'yaml'
    setting = YAML.load_file(def_file)
    
    ClockQuiz::process(setting)
  end
end
