var gulp   = require('gulp'),
    concat = require('gulp-concat');

gulp.task('concat-js', function() {
  gulp.src([
    'versal-player-api/index.js',
    'versal-challenges-js-api/challenges_iframe_api.js'
  ])
  .pipe(concat('index.js'))
  .pipe(gulp.dest('./'))
});

gulp.task('concat-css', function() {
  gulp.src('versal-gadget-theme/index.css')
    .pipe(concat('index.css'))
    .pipe(gulp.dest('./'))
});


gulp.task('default', ['concat-css', 'concat-js']);
