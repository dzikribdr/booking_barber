async function run() {
  // Since we can't run raw SQL from Anon key, let's just insert into bookings using dandi's ID to PROVE it works for dandi.
  const url = 'https://poeumcswufipbmecjobt.supabase.co/rest/v1/bookings';
  const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvZXVtY3N3dWZpcGJtZWNqb2J0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwNjE0MTcsImV4cCI6MjA5NTYzNzQxN30.SxL8QhxE6RJkp-yYyghI3PeUhk17_L-4ydc_q5XDwwk';
  try {
    // First let's get a valid service_id
    const sRes = await fetch('https://poeumcswufipbmecjobt.supabase.co/rest/v1/services?limit=1', { headers: { 'apikey': key, 'Authorization': `Bearer ${key}` } });
    const services = await sRes.json();
    if(services.length === 0) return;
    const service_id = services[0].id;
    
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        'apikey': key,
        'Authorization': `Bearer ${key}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
      },
      body: JSON.stringify({
        customer_id: 'c61e9558-68f5-4c15-99fe-0e4c6f492236', // dandi
        service_id: service_id,
        booking_time: new Date().toISOString(),
        status: 'pending'
      })
    });
    console.log(res.status);
    console.log(await res.text());
  } catch(e) {
    console.error(e);
  }
}
run();
