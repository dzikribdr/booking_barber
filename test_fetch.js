async function run() {
  const url = 'https://poeumcswufipbmecjobt.supabase.co/rest/v1/services';
  const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvZXVtY3N3dWZpcGJtZWNqb2J0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNjE0MTcsImV4cCI6MjA5NTYzNzQxN30.SxL8QhxE6RJkp-yYyghI3PeUhk17_L-4ydc_q5XDwwk';
  try {
    const res = await fetch(url, {
      headers: {
        'apikey': key,
        'Authorization': `Bearer ${key}`
      }
    });
    console.log(res.status);
    console.log(await res.text());
  } catch(e) {
    console.error(e);
  }
}
run();
