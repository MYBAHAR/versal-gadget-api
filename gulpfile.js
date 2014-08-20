var gulp   = require('gulp'),
    concat = require('gulp-concat');

gulp.task('concat-js', function() {
  gulp.src([
    'player-api/index.js',
    'challenges-js-api/challenges_iframe_api.js'
  ])
  .pipe(concat('index.js'))
  .pipe(gulp.dest('./'))
});

gulp.task('concat-css', function() {
  gulp.src('gadget-theme/index.css')
    .pipe(concat('index.css'))
    .pipe(gulp.dest('./'))
});


gulp.task('default', ['concat-css', 'concat-js']);
