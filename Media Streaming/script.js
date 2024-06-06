document.addEventListener("DOMContentLoaded", function () {
  const movies = [
    { name: "Movie 1", url: "http://10.1.1.244:8200/MediaItems/1.mp4" },
    { name: "Movie 2", url: "http://10.1.1.244:8200/MediaItems/2.mp4" },
    { name: "Movie 3", url: "http://10.1.1.244:8200/MediaItems/3.mp4" },
    { name: "Movie 4", url: "http://10.1.1.244:8200/MediaItems/1.mp4" },
  ];

  const movieList = document.getElementById("movie-list");

  movies.forEach((movie) => {
    const li = document.createElement("li");
    li.textContent = movie.name;

    const playButton = document.createElement("button");
    playButton.textContent = "Play";
    playButton.className = "play-button";
    playButton.addEventListener("click", (event) => {
      event.stopPropagation();
      window.location.href = movie.url;
    });

    li.appendChild(playButton);
    movieList.appendChild(li);
  });
});
